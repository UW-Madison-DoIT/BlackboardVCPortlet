package org.jasig.portlet.blackboardvcportlet.dao.ws.impl;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.when;
import static org.mockito.Matchers.any;

import java.util.List;
import java.util.Map;

import org.jasig.portlet.blackboardvcportlet.dao.ws.SessionWSDao;
import org.jasig.portlet.blackboardvcportlet.security.SecurityExpressionEvaluator;
import org.jasig.springframework.mockito.MockitoFactoryBean;
import org.joda.time.DateTime;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.support.DataAccessUtils;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.elluminate.sas.BlackboardSessionResponse;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:/test-applicationContext.xml")
public class SessionWSDaoIT extends AbstractWSIT {
	
	@Autowired
	private SessionWSDao dao;
	
	@Autowired
	private SecurityExpressionEvaluator security;
	
	@SuppressWarnings("unchecked")
	@Before
	public void before() {
		MockitoFactoryBean.resetAllMocks();
		when(security.authorize(any(String.class))).thenReturn(true);
		when(security.authorize(any(String.class),any(Map.class))).thenReturn(true);
		form = buildSession();
		user = buildUser();
		session = dao.createSession(user, form);
	}
	
	@After
	public void after() {
		List<BlackboardSessionResponse> sessions = dao.getSessions(null, null, null, user.getUniqueId(), null, null, null);
		for(BlackboardSessionResponse session : sessions ) {
			dao.deleteSession(session.getSessionId());			
		}
	}
	
	@Test
	public void createSessionTest() {
		//built session in before
		assertNotNull(session);
		
		assertEquals(session.getBoundaryTime(), form.getBoundaryTime());
		assertEquals(session.getEndTime(),form.getEndTime().getMillis());
		assertEquals(session.getStartTime(), form.getStartTime().getMillis());
		
		assertEquals(session.getCreatorId(), user.getUniqueId());
	}
	
	@Test
	public void updateSessionTest() {
		form.setNewSession(false);
		form.setSessionId(session.getSessionId());
		
		//go from 3 to 4 (four hour meeting)
		form.setEndTime((new DateTime()).plusHours(4).withMinuteOfHour(0).withSecondOfMinute(0).withMillisOfSecond(0));
		BlackboardSessionResponse updateSession = dao.updateSession(session.getSessionId(), form);
		assertNotNull(updateSession);
		assertEquals(form.getEndTime().getMillis(),updateSession.getEndTime());
	}
	
	@Test
	public void buildSessionGuestUrlTest() {
		String url = dao.buildGuestSessionUrl(session.getSessionId());
		assertNotNull(url);
		
	}
	
	/**
	 * This test case assumes the creator is initially added as a chair (moderator)
	 */
	@Test
	public void buildSessionUrlTest() {
		String url = dao.buildSessionUrl(session.getSessionId(), user);
		assertNotNull(url);
		
	}
	
	@Test
	public void getSessionsByEmailAddressTest() {
		
		List<BlackboardSessionResponse> sessions = dao.getSessions(null, null, null, session.getCreatorId(), null, null, null);
		assertNotNull(sessions);
		assertEquals(DataAccessUtils.singleResult(sessions).getSessionId(), session.getSessionId());
	}
	
	@Test
	public void getSessionsBySessionIdTest() {
		
		List<BlackboardSessionResponse> sessions = dao.getSessions(null, null, session.getSessionId(), null, null, null, null);
		assertNotNull(sessions);
		assertEquals(DataAccessUtils.singleResult(sessions).getSessionId(), session.getSessionId());
	}
	
	@Test
	public void clearSessionChairList() {
		assertTrue(dao.clearSessionChairList(session.getSessionId()));
		List<BlackboardSessionResponse> sessions = dao.getSessions(null, null, session.getSessionId(), null, null, null, null);
		BlackboardSessionResponse singleSession = DataAccessUtils.singleResult(sessions);
		assertTrue(singleSession.getChairList().isEmpty());
	}
	
	@Test
	public void clearSessionNonChairList() {
		assertTrue(dao.clearSessionNonChairList(session.getSessionId()));
		List<BlackboardSessionResponse> sessions = dao.getSessions(null, null, session.getSessionId(), null, null, null, null);
		BlackboardSessionResponse singleSession = DataAccessUtils.singleResult(sessions);
		assertTrue(singleSession.getNonChairList().isEmpty());
	}
}
