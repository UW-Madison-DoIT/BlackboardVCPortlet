/**
 * Licensed to Jasig under one or more contributor license
 * agreements. See the NOTICE file distributed with this work
 * for additional information regarding copyright ownership.
 * Jasig licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a
 * copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.jasig.portlet.blackboardvcportlet.mvc.sessionmngr;

import com.google.common.collect.Ordering;
import static ch.lambdaj.Lambda.*;

import net.sf.ehcache.search.expression.GreaterThan;

import org.apache.commons.collections.ListUtils;
import org.apache.commons.collections.SetUtils;
import org.hamcrest.*;
import org.jasig.portlet.blackboardvcportlet.dao.ConferenceUserDao;
import org.jasig.portlet.blackboardvcportlet.dao.SessionDao;
import org.jasig.portlet.blackboardvcportlet.data.ConferenceUser;
import org.jasig.portlet.blackboardvcportlet.data.Session;
import org.jasig.portlet.blackboardvcportlet.data.SessionRecording;
import org.jasig.portlet.blackboardvcportlet.security.ConferenceUserService;
import org.jasig.portlet.blackboardvcportlet.service.SessionService;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.portlet.bind.annotation.RenderMapping;
import javax.portlet.PortletRequest;
import javax.portlet.WindowState;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Controller for handling Portlet view mode
 *
 * @author Richard Good
 */
@Controller
@RequestMapping("VIEW")
public class ViewSessionListController
{
	protected final Logger logger = LoggerFactory.getLogger(getClass());

	private ConferenceUserService conferenceUserService;
	private SessionDao sessionDao;
	private SessionService sessionService;
	private ConferenceUserDao conferenceUserDao;

	@Autowired
    public void setConferenceUserService(ConferenceUserService conferenceUserService) {
        this.conferenceUserService = conferenceUserService;
    }

	@Autowired
	public void setSessionService(SessionService service) {
		this.sessionService = service;
	}

	@Autowired
    public void setSessionDao(SessionDao sessionDao) {
        this.sessionDao = sessionDao;
    }

    @Autowired
    public void setConferenceUserDao(ConferenceUserDao conferenceUserDao) {
        this.conferenceUserDao = conferenceUserDao;
    }

	@RenderMapping
	public String view(PortletRequest request, ModelMap model, @RequestParam(required = false) String deleteSessionError, @RequestParam(required = false) String deleteRecordingError)
	{
		final ConferenceUser conferenceUser = this.conferenceUserService.getCurrentConferenceUser();

		//Get all the sessions for the user
		final Set<Session> sessions = new HashSet<Session>();

		final Set<Session> ownedSessionsForUser = this.conferenceUserDao.getOwnedSessionsForUser(conferenceUser);
        sessions.addAll(ownedSessionsForUser);

        final Set<Session> chairedSessionsForUser = this.conferenceUserDao.getChairedSessionsForUser(conferenceUser);
        sessions.addAll(chairedSessionsForUser);

        final Set<Session> nonChairedSessionsForUser = this.conferenceUserDao.getNonChairedSessionsForUser(conferenceUser);
        sessions.addAll(nonChairedSessionsForUser);

        Matcher<DateTime> afterNow = new BaseMatcher<DateTime>() {
			@Override
			public void describeTo(Description arg0) {
				//don't care
			}

			@Override
			public boolean matches(Object arg0) {
				DateTime now = DateTime.now();
				DateTime arg = (DateTime)arg0;
				return arg.isAfter(now);
			}
		};

		Matcher<DateTime> beforeOrIsNow = new BaseMatcher<DateTime>() {
			@Override
			public void describeTo(Description arg0) {
				//don't care
			}

			@Override
			public boolean matches(Object arg0) {
				DateTime now = DateTime.now();
				DateTime arg = (DateTime)arg0;
				return arg.isBefore(now) || arg.isEqualNow();
			}
		};


        //this.is.awesome!
        List<Session> upcomingSessions = filter(having(on(Session.class).getEndTime(),afterNow),sessions);
        List<Session> completedSessions = filter(having(on(Session.class).getEndTime(),beforeOrIsNow),sessions);

		model.addAttribute("completedSessions", Ordering.from(SessionDisplayComparator.INSTANCE).sortedCopy(completedSessions));
		model.addAttribute("upcomingSessions", Ordering.from(SessionDisplayComparator.INSTANCE).sortedCopy(upcomingSessions));

		if (deleteSessionError != null)
		{
			model.addAttribute("deleteSessionError", deleteSessionError);
		}

		if (deleteRecordingError != null)
		{
			model.addAttribute("deleteRecordingError", deleteRecordingError);
		}

		final Set<SessionRecording> recordings = new HashSet<SessionRecording>();
		for (final Session session : sessions) {
			//Get information for all sessions
		    final Set<SessionRecording> sessionRecordings = this.sessionDao.getSessionRecordings(session);
		    recordings.addAll(sessionRecordings);

		    //get launch URL
		    sessionService.populateLaunchUrl(conferenceUser, session);
		}
		model.addAttribute("recordings", Ordering.from(SessionRecordingDisplayComparator.INSTANCE).sortedCopy(recordings));

		if(WindowState.MAXIMIZED.equals(request.getWindowState())
				|| "exclusive".equals(request.getWindowState().toString())) {
			return "viewSessionsMax";
		} else {
			return "viewSessionsNormal";
		}
	}
}
