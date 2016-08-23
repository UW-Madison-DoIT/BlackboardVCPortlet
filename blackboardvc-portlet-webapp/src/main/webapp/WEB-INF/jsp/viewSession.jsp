<%--

    Licensed to Jasig under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Jasig licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License. You may obtain a
    copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on
    an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the License for the
    specific language governing permissions and limitations
    under the License.

--%>
<div class="fl-widget portlet error view-detailed" role="section">

<%@ include file="/WEB-INF/jsp/include.jsp"%>
<%@ include file="/WEB-INF/jsp/header.jsp"%>

<div id="${n}blackboardCollaboratePortlet" class="blackboardVCRoot">
<c:if test="${!empty prefs['helpUrl'][0]}">
	<div class="help-link">
	  <a href="${createSessionUrl }" id="create-user" class="btn btn-small-blue uportal-button"><spring:message code="scheduleWebConferencingSession" text="scheduleWebConferencingSession"/></a>
	  <a href="${prefs['helpUrl'][0]}" target="_blank" class="btn btn-default uportal-button"><spring:message code="help" text="help"/></a>
	</div>
</c:if>
<portlet:renderURL var="backUrl" portletMode="VIEW" />
<a href="${backUrl}" class="btn btn-default uportal-button">&lt; Back to Session List</a>
<br/>

<div class="viewSession">
	<div class="row">
		<div class="col-md-9">
			<div class="col-md-12">
				<div class="session-large-heading">${session.sessionName}</div>
				<span class="session-status">
				<c:choose>
				       <c:when test="${session.endTime.beforeNow}">
				         <spring:message code="sessionIsClosed" text="sessionIsClosed"/>
				       </c:when>
				       <c:otherwise>
				     	<c:choose>
				  	   <c:when test="${session.startTimeWithBoundaryTime.beforeNow}">
				  	      	<a href='${session.launchUrl}' target="_blank"><spring:message code="joinNow" text="joinNow"/></a>
				  	   </c:when>
				  	   <c:otherwise>
				  	    	${session.timeUntilJoin}
				  	   </c:otherwise>
				         </c:choose>
				       </c:otherwise>
			       </c:choose>
		   		</span>
		   		<div class="session-date-time">
		   			<joda:format value="${session.startTime}" pattern="MMM dd, yyyy hh:mm a z" /> to <joda:format value="${session.endTime}" pattern="MMM dd, yyyy hh:mm a z" />
		   		</div>
		   		<div class="session-moderator">
		   			<sec:authorize access="hasRole('ROLE_ADMIN') || hasPermission(#session, 'edit')">
					      <label for="moderatorLinkDesc">
					                <span class="uportal-channel-strong">
					                    <spring:message code="moderatorLink" text="moderatorLink"/>
					                </span>
					               
					            </label>
					        <a href="${session.launchUrl}" target="_blank">${session.launchUrl}</a>
					        <span class="session-descriptive-text"><spring:message code="moderatorLinkDesc" text="moderatorLinkDesc"/></span>
					    </sec:authorize>
		   		</div>
			</div>
		</div>
		<div class="col-md-3">
			<sec:authorize access="hasRole('ROLE_ADMIN') || hasPermission(#session, 'edit')">
				<portlet:renderURL var="editSessionUrl" portletMode="EDIT" windowState="${windowState}" >
					<portlet:param name="sessionId" value="${session.sessionId}" />
					<portlet:param name="action" value="editSession" />
				</portlet:renderURL>
	  			<a href="${editSessionUrl}" class="btn btn-default uportal-button"><spring:message code="editSession" text="Edit Session"/></a>
			</sec:authorize>
		</div>
	</div>
</div>
<div class="viewSession">
	<div class="row">
		<div class="col-md-12">
			<div class="session-large-heading">Invite participants to your web conference</div>
			<p>There are 2 ways to invite participants to your web conference.  Invite participants and update participant session settngs.</p>
			<div class="session-guest-choice-one">
				<div class="session-medium-heading">Send participants a Guest Link they can share publically</div>
				<sec:authorize access="hasRole('ROLE_ADMIN') || hasPermission(#session, 'edit')">
		    	<label for="guestLink">
		                <span class="uportal-channel-strong">
		                    <spring:message code="guestLink" text="guestLink"/>
		                </span>
		                </label>
		            <a href="${session.guestUrl}" target="_blank">${session.guestUrl}</a>
		            <span class="session-descriptive-text"><spring:message code="guestLinkDesc" text="guestLinkDesc"/></span>
		    	</sec:authorize>
			</div>
			<div class="divider"><span>OR</span></div>
			<div class="session-guest-choice-two">

				<div class="session-medium-heading">Send participants an email invite</div>
				<span class="session-descriptive-text">Use this to invite participants to a private web conference session via email. Participants will recieve a unique link to enter their session.</span>
				<sec:authorize access="hasRole('ROLE_ADMIN') || hasPermission(#session, 'edit')">
			    	<portlet:renderURL var="addParticipantsUrl" portletMode="EDIT" windowState="${windowState}">
					    <portlet:param name="sessionId" value="${session.sessionId}" />
					    <portlet:param name="action" value="addParticipants" />
					</portlet:renderURL>
			    	<a href="${addParticipantsUrl}" class="btn btn-default uportal-button">+ Email Participants</a>
				</sec:authorize>	

			<ul>
		      <c:forEach var="user" items="${sessionChairs}">
		        <li>${user.displayName} (<spring:message code="moderator" text="moderator"/>)</li>
		      </c:forEach>
		      <c:forEach var="user" items="${sessionNonChairs}">
		        <li>${user.displayName}</li>
		      </c:forEach>
		    </ul>
		    
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-12">
		<hr />
	</div>
</div>

<div class="viewSession">
	<div class="row">
		<div class="col-md-12">
			<c:if test="${telephonyEnabled eq 'true' }" >
			<table>
				<tr>
					<th style="text-align: left;">Telephony Information</th>
					<th style="text-align: right">
						<sec:authorize access="hasRole('ROLE_ADMIN') || hasPermission(#session, 'edit')">
							<portlet:renderURL var="configTelephonyURL" portletMode="EDIT" windowState="${windowState}">
								<portlet:param name="sessionId" value="${session.sessionId}" />
							    <portlet:param name="action" value="configureTelephony" />
							</portlet:renderURL>
							<a href="${configTelephonyURL }" class="btn btn-default uportal-button">Configure Telephony</a>
						</sec:authorize>
					</th>
				</tr>
				<c:choose>
					<c:when test="${!empty sessionTelephony }">
						<sec:authorize access="hasRole('ROLE_ADMIN') || hasPermission(#session, 'edit')">
							<!-- Only want to see chair number/pin if chair -->
							<tr class="even">
								<td>
		                            <label for="moderatorPhone">
		                                <span class="uportal-channel-strong">
		                                    <spring:message code="moderatorPhone" text="Moderator Phone" />
		                                </span>
		                            </label>
								</td>
								<td>
									${sessionTelephony.chairPhone }<c:if test="${!empty sessionTelephony.chairPIN }">&nbsp;PIN: ${sessionTelephony.chairPIN }</c:if>
								</td>
							</tr>
						</sec:authorize>
						<tr class="odd">
							<td>
		                        <label for="participantPhone">
		                            <span class="uportal-channel-strong">
		                                <spring:message code="participantPhone" text="Participant Phone" />
		                            </span>
		                        </label>
							</td>
							<td>
								${sessionTelephony.nonChairPhone } <c:if test="${!empty sessionTelephony.nonChairPIN }">&nbsp;PIN:&nbsp;${sessionTelephony.nonChairPIN }</c:if>
							</td>
						</tr>
						<tr class="even">
							<td>
		                        <label for="SIPPhone">
		                            <span class="uportal-channel-strong">
		                                <spring:message code="SIPPhone" text="SIP Phone" />
		                            </span>
		                        </label>
							</td>
							<td>
								${sessionTelephony.sessionSIPPhone } <c:if test="${!empty sessionTelephony.sessionPIN }">&nbsp;PIN:&nbsp;${sessionTelephony.sessionPIN }</c:if>
							</td>
						</tr>
					</c:when>
					<c:otherwise>
						<tr>
							<td colspan='2'><spring:message code="notelephony" text="No Telephony set. This session will utilize the default integrated telephony."/></td>
						</tr>
					</c:otherwise>
				</c:choose>
			</table>
		</c:if>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-12">
		<hr />
	</div>
</div>



<br/>
<table class="viewSession">
	<tr>
		<th colspan="2" style="text-align :left;"><spring:message code="additionalInfo" text="Additional Information"/></th>
	</tr>
	
	<tr class="odd">
		<td>
            <label for="presentationFile">
                <span class="uportal-channel-strong">
                    <spring:message code="presentationFile" text="Presentation File" />
                </span>
                <spring:message code="tooltip.presentationFile" text="tooltip.presentationFile" var="tooltipPresentationFile" htmlEscape="false" />
                &nbsp;<a href="#" title="${ tooltipPresentationFile}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
                <br/>
                <span class="session-descriptive-text"><spring:message code="presentationFileDesc" text="" /></span>
            </label>
		</td>
		<td>
			<portlet:actionURL portletMode="EDIT" var="managePresentationActionUrl" />
		    <form action="${managePresentationActionUrl}" method="post" enctype="multipart/form-data">
		      <input type="hidden" name="sessionId" value="${session.sessionId}" />
		      <input type="hidden" name="needToSendInitialEmail" value="false" />
			
			  <c:choose>
			  <c:when test="${!empty session.presentation }">
				  ${session.presentation.filename } 
				  &nbsp;
				  <portlet:actionURL var="deletePresentationURL" portletMode="EDIT">
				    <portlet:param name="sessionId" value="${session.sessionId}" />
				    <portlet:param name="action" value="deletePresentation" />
				</portlet:actionURL>
		    	<a href="${deletePresentationURL}" class="destroy" title="Delete">&nbsp;</a>
			  </c:when>
			  <c:otherwise>
			  	No Presentation Uploaded
			  </c:otherwise>
			  </c:choose>
			  <br/>
              <span class="btn btn-default uploadButton">
			     <input name="presentationUpload" size="40" type="file" accept="${presentationFileTypes}">
              </span>
              <br/>
              <c:if test="${!empty presentationUploadError}">
                  <span class="error">${presentationUploadError}</span>
              </c:if>
              <spring:message code="uploadPresentation" var="uploadPresentation" text="uploadPresentation"/>
           	  <input value="${uploadPresentation}" name="action" class="btn btn-default uportal-button" type="submit">
           	</form>
		</td>
	</tr>
	<tr class="even">
		<td>
            <label for="mediaFiles">
                <span class="uportal-channel-strong">
                    <spring:message code="mediaFiles" text="Media Files" />
                </span>
                <spring:message code="tooltip.mediaFiles" text="tooltip.mediaFiles" var="tooltipMediaFiles" htmlEscape="false" />
                &nbsp;<a href="#" title="${ tooltipMediaFiles}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
                <br/>
                <span class="session-descriptive-text"><spring:message code="mediaFilesDesc" text="" /></span>
            </label>
		</td>
		<td>
			<c:choose>
				<c:when test="${!empty multimedias }">
					<ul>
						<c:forEach items="${multimedias}" var="multimediaItem" varStatus="loopStatus">
				            <li>${multimediaItem.filename}</li>
				        </c:forEach>
			        </ul>
	        	</c:when>
	        	<c:otherwise>
	        		No Media files Uploaded
	        		<br/>
	        	</c:otherwise>
        	</c:choose>
			<portlet:renderURL var="addMediaFileUrl" portletMode="EDIT" windowState="${windowState}" >
			    <portlet:param name="sessionId" value="${session.sessionId}" />
			    <portlet:param name="action" value="manageMediaFiles" />
			</portlet:renderURL>
	    	<a href="${addMediaFileUrl}" class="btn btn-default uportal-button">Upload Media File(s)</a>
		</td>
	</tr>
	<tr class="odd">
		<td>
            <label for="recordings">
                <span class="uportal-channel-strong">
                    <spring:message code="recordings" text="Recordings" />
                </span>
                <spring:message code="tooltip.recordings" text="tooltip.recordings" var="tooltipRecordings" htmlEscape="false" />
                &nbsp;<a href="#" title="${ tooltipRecordings}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
            </label>
		</td>
		<td>
			<c:choose>
				<c:when test="${!empty recordings }">
			<ul>
				<c:forEach items="${recordings }" var="recording">
					<li><a href="${recording.recordingUrl}" target="_blank">${recording.roomName}</a></li>
				</c:forEach>
			</ul>
			</c:when>
			<c:otherwise>
				No Recordings available
			</c:otherwise>
			</c:choose>
		</td>
	</tr>
</table>   
<div class="row">
	<div class="col-md-12">
		<a href="${backUrl}" class="btn btn-default btn-green uportal-button">Save Session</a>
	</div>
</div>
<script type="text/javascript">
(function($) {
   $(document).ready(function() {
      blackboardPortlet.showTooltip('.${n}toolTip');
   });			
})(blackboardPortlet.jQuery);
</script>
<c:if test="${saveMessage eq 'true' }">
<script type="text/javascript">
(function($) {
    $('.blackboardVCRoot').before("<div class='blackboardVCRoot-notification-success'>The web conference has been saved.</div>");
    $('.blackboardVCRoot-notification-success').click(function(){$('.blackboardVCRoot-notification-success').fadeOut();});
})(up.jQuery);
</script>
</c:if>

</div>
</div>