package org.jasig.portlet.blackboardvcportlet.dao.impl;

import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.regex.Pattern;

import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.Validate;
import org.jasig.jpa.BaseJpaDao;
import org.jasig.jpa.OpenEntityManager;
import org.jasig.portlet.blackboardvcportlet.data.AccessType;
import org.jasig.portlet.blackboardvcportlet.data.ConferenceUser;
import org.jasig.portlet.blackboardvcportlet.data.RecordingMode;
import org.jasig.portlet.blackboardvcportlet.data.Session;
import org.jasig.portlet.blackboardvcportlet.data.SessionRecording;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.elluminate.sas.BlackboardSessionResponse;
import com.google.common.base.Function;
import com.google.common.collect.ImmutableSet;

@Repository
public class SessionDaoImpl extends BaseJpaDao implements InternalSessionDao {
    private static final Pattern USER_LIST_DELIM = Pattern.compile(",");
    
    private CriteriaQuery<SessionImpl> findAllSessions;
    
    private InternalConferenceUserDao blackboardUserDao;

    @Autowired
    public void setBlackboardUserDao(InternalConferenceUserDao blackboardUserDao) {
        this.blackboardUserDao = blackboardUserDao;
    }
    
    @Override
    public void afterPropertiesSet() throws Exception {
        this.findAllSessions = this.createCriteriaQuery(new Function<CriteriaBuilder, CriteriaQuery<SessionImpl>>() {
            @Override
            public CriteriaQuery<SessionImpl> apply(CriteriaBuilder cb) {
                final CriteriaQuery<SessionImpl> criteriaQuery = cb.createQuery(SessionImpl.class);
                final Root<SessionImpl> definitionRoot = criteriaQuery.from(SessionImpl.class);
                criteriaQuery.select(definitionRoot);

                return criteriaQuery;
            }
        });
    }
    
    @Override
    public Set<Session> getAllSessions() {
        final TypedQuery<SessionImpl> query = this.createQuery(this.findAllSessions);
        return new LinkedHashSet<Session>(query.getResultList());
    }

    @Override
    public Set<ConferenceUser> getSessionChairs(Session session) {
        if (session == null) {
            return null;
        }
        
        final SessionImpl sessionImpl = this.getSession(session.getSessionId());
        if (sessionImpl == null) {
            return null;
        }

        //Create a copy to trigger loading of the user data
        return ImmutableSet.copyOf(sessionImpl.getChairs());
    }

    @Override
    public Set<ConferenceUser> getSessionNonChairs(Session session) {
        if (session == null) {
            return null;
        }
        
        final SessionImpl sessionImpl = this.getSession(session.getSessionId());
        if (sessionImpl == null) {
            return null;
        }

        //Create a copy to trigger loading of the user data
        return ImmutableSet.copyOf(sessionImpl.getNonChairs());
    }
    
    @Override
    public Set<SessionRecording> getSessionRecordings(Session session) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException();
    }

    @Override
    public SessionImpl getSession(long sessionId) {
        final EntityManager entityManager = this.getEntityManager();
        return entityManager.find(SessionImpl.class, sessionId);
    }

    @Override
    @OpenEntityManager
    public SessionImpl getSessionByBlackboardId(long bbSessionId) {
        final NaturalIdQuery<SessionImpl> query = this.createNaturalIdQuery(SessionImpl.class);
        query.using(SessionImpl_.bbSessionId, bbSessionId);
        
        return query.load();
    }

    @Override
    @Transactional
    public SessionImpl createSession(BlackboardSessionResponse sessionResponse, String guestUrl) {
        //Find the creator user
        final String creatorId = sessionResponse.getCreatorId();
        final ConferenceUser creator = this.blackboardUserDao.getOrCreateUser(creatorId);
        
        //Create and populate a new blackboardSession
        final SessionImpl blackboardSession = new SessionImpl(sessionResponse.getSessionId(), creator);
        updateBlackboardSession(sessionResponse, blackboardSession);
        
        blackboardSession.setGuestUrl(guestUrl);

        //Persist and return the new session
        this.getEntityManager().persist(blackboardSession);
        return blackboardSession;
    }

    @Override
    @Transactional
    public SessionImpl updateSession(BlackboardSessionResponse sessionResponse) {
        //Find the existing blackboardSession
        final SessionImpl blackboardSession = this.getSessionByBlackboardId(sessionResponse.getSessionId());
        if (blackboardSession == null) {
            //TODO should this automatically fall back to create?
            throw new IncorrectResultSizeDataAccessException("No BlackboardSession could be found for sessionId " + sessionResponse.getSessionId(), 1);
        }
        
        //Copy over the response data
        updateBlackboardSession(sessionResponse, blackboardSession);
        
        this.getEntityManager().persist(blackboardSession);
        return blackboardSession;
    }

    @Override
    @Transactional
    public void deleteSession(Session session) {
        Validate.notNull(session, "session can not be null");
        
        final EntityManager entityManager = this.getEntityManager();
        if (!entityManager.contains(session)) {
            session = entityManager.merge(session);
        }
        entityManager.remove(session);        
    }

    /**
     * Sync all data from the {@link BlackboardSessionResponse} to the {@link SessionImpl}
     */
    private void updateBlackboardSession(BlackboardSessionResponse sessionResponse, SessionImpl session) {
        session.setAccessType(AccessType.resolveAccessType(sessionResponse.getAccessType()));
        session.setAllowInSessionInvites(sessionResponse.isAllowInSessionInvites());
        session.setBoundaryTime(sessionResponse.getBoundaryTime());
        session.setChairNotes(sessionResponse.getChairNotes());
        session.setEndTime(DaoUtils.toDateTime(sessionResponse.getEndTime()));
        session.setHideParticipantNames(sessionResponse.isHideParticipantNames());
        session.setMaxCameras(sessionResponse.getMaxCameras());
        session.setMaxTalkers(sessionResponse.getMaxTalkers());
        session.setMustBeSupervised(sessionResponse.isMustBeSupervised());
        session.setNonChairNotes(sessionResponse.getNonChairNotes());
        session.setOpenChair(sessionResponse.isOpenChair());
        session.setRaiseHandOnEnter(sessionResponse.isRaiseHandOnEnter());
        session.setRecordingMode(RecordingMode.resolveRecordingMode(sessionResponse.getRecordingModeType()));
        session.setRecordings(sessionResponse.isRecordings());
        session.setReserveSeats(sessionResponse.getReserveSeats());
        session.setSessionName(sessionResponse.getSessionName());
        session.setStartTime(DaoUtils.toDateTime(sessionResponse.getStartTime()));
        session.setVersionId(sessionResponse.getVersionId());
        session.setPermissionsOn(sessionResponse.isPermissionsOn());
        session.setSecureSignOn(sessionResponse.isSecureSignOn());
        
        updateUserList(sessionResponse, session, UserListType.CHAIR);
        
        updateUserList(sessionResponse, session, UserListType.NON_CHAIR);
    }
    
    
    /**
     * Syncs the user list (chair or non-chair) from the {@link BlackboardSessionResponse} to the {@link SessionImpl}. Handles
     * creating/updating the associated {@link ConferenceUser} objects
     * 
     * @param sessionResponse Source of user list data
     * @param blackboardSession Destination to be updated with user list data
     * @param type The type of user list data to sync
     */
    private void updateUserList(BlackboardSessionResponse sessionResponse, SessionImpl blackboardSession, UserListType type) {
        final String userList = type.getUserList(sessionResponse);
        final String[] userIds = USER_LIST_DELIM.split(userList);
        
        final Set<ConferenceUser> existingUsers = type.getUserSet(blackboardSession);
        final Set<ConferenceUser> newUsers = new HashSet<ConferenceUser>(userIds.length);
        for (String userId : userIds) {
            userId = StringUtils.trimToNull(userId);
            
            //Skip empty/null userIds
            if (userId == null) {
                continue;
            }
            
            //find the DB user object for the chair
            final ConferenceUserImpl user = this.blackboardUserDao.getOrCreateUser(userId);
            
            //Update the user's set of chaired sessions
            final boolean added = type.associateSession(user, blackboardSession);
            
            //User was modified, make sure we tell hibernate to persist them
            if (added) {
                this.blackboardUserDao.updateBlackboardUser(user);
            }
            
            //Add the user to the new set and make sure the user is in the existing set
            newUsers.add(user);
            existingUsers.add(user);
        }
        
        //Use this approach to remove any users that are no longer in the list. Mutating the existing
        //collection is slightly more expensive in CPU time but significantly less expensive for the
        //hibernate layer to persist
        for (final Iterator<ConferenceUser> existingUserItr = existingUsers.iterator(); existingUserItr.hasNext();) {
            final ConferenceUser existingUser = existingUserItr.next();
            //Check each existing user to see if they should no longer be a chair
            if (!newUsers.contains(existingUser)) {
                //Remove from existing chairs set
                existingUserItr.remove();
                
                //Update the user's associate with the session
                final ConferenceUserImpl user = this.blackboardUserDao.getUser(existingUser.getUserId());
                final boolean removed = type.unassociateSession(user, blackboardSession);
                if (removed) {
                    this.blackboardUserDao.updateBlackboardUser(user);
                }
            }
        }
    }
    
    /**
     * Utility enum to hide the specific methods involved with updating chair vs
     * non-chair user to session associations.
     */
    private enum UserListType {
        CHAIR {
            @Override
            public String getUserList(BlackboardSessionResponse sessionResponse) {
                return sessionResponse.getChairList();
            }

            @Override
            public Set<ConferenceUser> getUserSet(SessionImpl blackboardSession) {
                return blackboardSession.getChairs();
            }

            @Override
            public boolean associateSession(ConferenceUserImpl user, Session session) {
                return user.getChairedSessions().add(session);
            }

            @Override
            public boolean unassociateSession(ConferenceUserImpl user, Session session) {
                return user.getChairedSessions().remove(session);
            }
        },
        NON_CHAIR{
            @Override
            public String getUserList(BlackboardSessionResponse sessionResponse) {
                return sessionResponse.getNonChairList();
            }

            @Override
            public Set<ConferenceUser> getUserSet(SessionImpl blackboardSession) {
                return blackboardSession.getNonChairs();
            }

            @Override
            public boolean associateSession(ConferenceUserImpl user, Session session) {
                return user.getNonChairedSessions().add(session);
            }

            @Override
            public boolean unassociateSession(ConferenceUserImpl user, Session session) {
                return user.getNonChairedSessions().remove(session);
            }
        };
        
        abstract String getUserList(BlackboardSessionResponse sessionResponse);
        
        abstract Set<ConferenceUser> getUserSet(SessionImpl blackboardSession);
        
        abstract boolean associateSession(ConferenceUserImpl user, Session session);
        
        abstract boolean unassociateSession(ConferenceUserImpl user, Session session);
    }
}