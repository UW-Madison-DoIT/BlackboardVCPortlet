package org.jasig.portlet.blackboardvcportlet.service.impl;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.List;

import org.jasig.portlet.blackboardvcportlet.dao.JobMutexDao;
import org.jasig.portlet.blackboardvcportlet.dao.SessionRecordingDao;
import org.jasig.portlet.blackboardvcportlet.dao.ws.RecordingWSDao;
import org.jasig.portlet.blackboardvcportlet.data.SessionRecording;
import org.jasig.portlet.blackboardvcportlet.service.RecordingService;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.support.DataAccessUtils;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ws.client.WebServiceClientException;

import com.elluminate.sas.BlackboardRecordingLongResponse;
import com.elluminate.sas.BlackboardRecordingShortResponse;

@Service("recordingService")
public class RecordingServiceImpl implements RecordingService {

	private RecordingWSDao recordingWSDao;
	private SessionRecordingDao recordingDao;
	private JobMutexDao jobMutexDao;
	private static final String RECORDING_DATA_FIX = "RECORDING_DATA_FIX";
	protected final Logger logger = LoggerFactory.getLogger(getClass());

	@Autowired
	public void setRecordingWSDao (RecordingWSDao recordingWSDao) {
		this.recordingWSDao = recordingWSDao;
	}

	@Autowired
	public void setJobMutexDao (JobMutexDao dao) {
	  this.jobMutexDao = dao;
	}

	@Autowired
	public void setRecordingDao (SessionRecordingDao dao) {
		this.recordingDao = dao;
	}

    @Override
    public void updateSessionRecordings(long sessionId, long startTime, long endTime) {
        //fetch the recording long information from the web service
		List<BlackboardRecordingLongResponse> recordingLongList = recordingWSDao.getRecordingLong(null, null, sessionId, null, startTime, endTime, null);
		BlackboardRecordingLongResponse recordingResponse = DataAccessUtils.singleResult(recordingLongList);
    	//post the information to the database
		recordingDao.createOrUpdateRecording(recordingResponse);
    }

    @Override
    @PreAuthorize("hasRole('ROLE_ADMIN') || hasPermission(#recordingId, 'org.jasig.portlet.blackboardvcportlet.data.SessionRecording', 'view')")
    public SessionRecording getSessionRecording(long recordingId) {
        return this.recordingDao.getSessionRecording(recordingId);
    }

    @Override
    @Transactional
    @PreAuthorize("hasRole('ROLE_ADMIN') || hasPermission(#recordingId, 'org.jasig.portlet.blackboardvcportlet.data.SessionRecording', 'edit')")
    public void updateSessionRecordingName(long recordingId, String roomName) {
        final SessionRecording sessionRecording = this.recordingDao.getSessionRecording(recordingId);
        sessionRecording.setRoomName(roomName);
        this.recordingDao.updateSessionRecording(sessionRecording);
    }

    @Override
    @Transactional
    @PreAuthorize("hasRole('ROLE_ADMIN') || hasPermission(#recordingId, 'org.jasig.portlet.blackboardvcportlet.data.SessionRecording', 'delete')")
    public void removeRecording(long recordingId) {
        final SessionRecording sessionRecording = this.recordingDao.getSessionRecording(recordingId);

        try {
            this.recordingWSDao.removeRecording(sessionRecording.getBbRecordingId());
        }
        catch (WebServiceClientException e) {
            //See if the recording actually exists
            final List<BlackboardRecordingShortResponse> recordings = this.recordingWSDao.getRecordingShort(null, null, sessionRecording.getSession().getBbSessionId(), null, null, null, null);

            boolean exists = false;
            for (final BlackboardRecordingShortResponse recording : recordings) {
                if (recording.getRecordingId() == sessionRecording.getBbRecordingId()) {
                    exists = true;
                    break;
                }
            }

            //Recording exists but we failed to remove it, throw the exception
            if (exists) {
                throw e;
            }

            //Recording doesn't exist on the BB side, remove our local DB version
        }
        this.recordingDao.deleteRecording(sessionRecording);
    }

    @PreAuthorize("hasRole('ROLE_ADMIN')")
    @Override
    public int[] datafixRecordings(DateTime startDate, DateTime endDate) {
      return datafixRecordings(startDate, endDate, false);
    }

    /**
     *
     * @param startDate beginning datetime
     * @param endDate end datetime
     * @param cron ran from cron?
     * @return returns a int[3]. int[0] is number of recordings processed. int[1] is how many added to local cache that were missing. int[2] is how many erred.
     */
    private int[] datafixRecordings(DateTime startDate, DateTime endDate, boolean cron) {
       int[] returnArray = {0,0,0};
       //fetch the recording long information from the web service
        List<BlackboardRecordingLongResponse> recordingLongList = recordingWSDao.getRecordingLong(null, null, null, null, startDate.getMillis(), endDate.getMillis(), null);
        returnArray[0] = recordingLongList != null ? recordingLongList.size() : 0;
        for(BlackboardRecordingLongResponse recordingResponse : recordingLongList) {
            try{
                //post the information to the database
                SessionRecording recording = recordingDao.createOrUpdateRecording(recordingResponse);
                if(recording.isCreated()) {
                  returnArray[1]++;
                }
            } catch (Exception ex) {
                logger.error("Error adding datafix for recording: " + recordingResponse.getRecordingId() + " for session : " + recordingResponse.getSessionId(), ex);
                returnArray[2]++;
            }
        }
        return returnArray;
    }

    /**
     * Run cron job every day at 10am
     * @throws UnknownHostException
     */
    @Scheduled(cron = "0 0 0,12 * * *")
    @Override
    public void cronDatafixRecordings() throws UnknownHostException {
      try {
      if(jobMutexDao.startMutex(RECORDING_DATA_FIX, InetAddress.getLocalHost().getHostName())) {
        DateTime now = DateTime.now();
        //run 2 days into the past, just in case yesterday ran
        logger.debug("Ran job 'cronDatafixRecordings' on " + now);
        int[] ret = datafixRecordings(now.minusDays(2), now, true);
        logger.debug("Job 'cronDatafixRecordings' started: " + now + " and finished: " + DateTime.now() + ". Results: processed: "+ret[0]+" added : "+ret[1]+" erred: "+ret[2]+". See you tomorrow.");
        jobMutexDao.stopMutex(RECORDING_DATA_FIX);
      } else {
        logger.debug("Job " + RECORDING_DATA_FIX + " running on another server.");
      }
      } catch (Exception ex) {
        logger.error("Issue running " + RECORDING_DATA_FIX + ". Going to attempt to stop mutex",ex);
        jobMutexDao.stopMutex(RECORDING_DATA_FIX); //really try to stop it so it can run again next time
      }
    }
}
