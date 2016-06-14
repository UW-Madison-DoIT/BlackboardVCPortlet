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

<div id="${n}" class="blackboardVCRoot">
<c:if test="${!empty prefs['helpUrl'][0]}">
	<div class="help-link">
	  <a href="${prefs['helpUrl'][0]}" target="_blank" class="btn btn-default uportal-button"><spring:message code="help" text="help"/></a>
	</div>
</c:if>
<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all inner-nav" role="tablist">
    <li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active ui-tabs-selected" role="tab" tabindex="0" aria-controls="Pluto_996_u115l1n107_12861_tabs-1" aria-labelledby="ui-id-1" aria-selected="true"><a href="#Pluto_996_u115l1n107_12861_tabs-1" class="ui-tabs-anchor" role="presentation" tabindex="-1" id="ui-id-1">Scheduled sessions</a></li>
    <li class="ui-state-default ui-corner-top" role="tab" tabindex="-1" aria-controls="Pluto_996_u115l1n107_12861_tabs-2" aria-labelledby="ui-id-2" aria-selected="false"><a href="#Pluto_996_u115l1n107_12861_tabs-2" class="ui-tabs-anchor" role="presentation" tabindex="-1" id="ui-id-2">Past sessions</a></li>
  </ul>
<h2><spring:message code="scheduleSession" text="scheduleSession"/></h2>
<portlet:actionURL portletMode="EDIT" var="saveSessionActionUrl">
  <portlet:param name="action" value="saveSession" />
</portlet:actionURL>
<form action="${saveSessionActionUrl}" method="post">
  <%-- Using nestedPath as form:form does not work for portlets see: https://jira.springsource.org/browse/SPR-10382 --%>
  <spring:nestedPath path="sessionForm">
  <form:hidden path="sessionId"/>
  <form:hidden path="newSession" />
  <form:hidden path="needToSendInitialEmail" />
  <div class="bb-content-container">
	<h3><spring:message code="enterInfo" text="enterInfo"/></h3>
	
		<div class="form-group row">
		    <label for="sessionName" class="col-md-4"><spring:message code="sessionName" text="sessionName"/></label>
		    <div class="col-md-8">
			    <c:choose>
	                <c:when test="${sessionForm.newSession}">
	                    <form:input path="sessionName" placeholder="enter session name..." class="uportal-input-text" />&nbsp;&nbsp;<form:errors path="sessionName" cssClass="error"/>
	                </c:when>
	            <c:otherwise>
	                <form:input type="hidden" path="sessionName" readonly="true"/>
	                <c:out value="${sessionForm.sessionName}"/>
	            </c:otherwise>
	            </c:choose>
	        </div>
		  </div>

		  <div class="form-group row">
		    <label for="startDateAndTime" class="col-md-4"><spring:message code="startDateAndTime" text="startDateAndTime"/></label>
		    <div class="col-md-8">
				  <form:errors path="" cssClass="error"/>
		          <form:input id="${n}startdatepicker" class="date start" path="startDate" style="width: 82px;"/>&nbsp;
		          
		          <form:input id="${n}startHourMinute" class="time start ui-timepicker-input" path="startHourMinute" style="width: 82px;"/>&nbsp;
		          &nbsp;<spring:message code="centralTime" text="centralTime"/>
		          &nbsp;<form:errors path="startDate" cssClass="error"/>
		          &nbsp;<form:errors path="startHour" cssClass="error"/>
		          &nbsp;<form:errors path="startMinute" cssClass="error"/>
		          &nbsp;<form:errors path="startTime" cssClass="error"/>
		          <br/>
	          	<small class="text-muted">mm/dd/yyyy</small>
		      </div>
		  </div>
	
		<div class="form-group row">
		    <label for="endDateAndTime" class="col-md-4"><spring:message code="endDateAndTime" text="endDateAndTime"/></label>
		   <div class="col-md-8">
			   <span class="datepair">
	          <form:input id="${n}enddatepicker" class="date end" path="endDate" style="width: 82px;"/>&nbsp;
	          
	          <form:input id="${n}endHourMinute" class="time end ui-timepicker-input" path="endHourMinute" style="width: 82px;"/>&nbsp;
	          </span>
	          &nbsp;<spring:message code="centralTime" text="centralTime"/>&nbsp;
	          <form:errors path="endDate" cssClass="error"/>&nbsp;
	            <form:errors path="endHour" cssClass="error"/>&nbsp;
	            <form:errors path="endMinute" cssClass="error"/>&nbsp;
	            <form:errors path="endTime" cssClass="error"/>
	          <br/>
	          <small class="text-muted">mm/dd/yyyy</small>
	      </div>
		</div>
		  <h4>Session Details</h4>

		  <div class="form-group row">
		    <label for="boundaryTime" class="col-md-4"><spring:message code="earlySessionEntry" text="earlySessionEntry"/></label>
		        	<spring:message code="tooltip.earlySessionEntry" text="tooltip.earlySessionEntry" var="tooltipEarlySessionEntry" htmlEscape="false" />
					&nbsp;<a href="#" title="${ tooltipEarlySessionEntry}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
		    <div class="col-md-8">
		    	<form:select path="boundaryTime">
		            <form:option value="15"><spring:message code="boundryTime15Minutes" text="boundryTime15Minutes"/></form:option>
		            <form:option value="30"><spring:message code="boundryTime30Minutes" text="boundryTime30Minutes"/></form:option>
		            <form:option value="45"><spring:message code="boundryTime45Minutes" text="boundryTime45Minutes"/></form:option>
		            <form:option value="60"><spring:message code="boundryTime1Hour" text="boundryTime1Hour"/></form:option>
		            <form:option value="120"><spring:message code="boundryTime2Hours" text="boundryTime2Hours"/></form:option>
		            <form:option value="180"><spring:message code="boundryTime3Hours" text="boundryTime3Hours"/></form:option>
		          </form:select>
		      </div>
		  </div>
		  
		  		
		  		<%-- <sec:authorize var="fullAccess" access="hasRole('ROLE_FULL_ACCESS')" /> --%>
		      <c:set value="true" var="fullAccess"/> 
		      <c:choose>
		        <c:when test="${fullAccess}">
			        <div class="form-group row">
			        	<div class="col-md-4">
			        		<span class="uportal-channel-strong"><spring:message code="maxSimultaneousTalkers" text="maxSimultaneousTalkers"/></span>
			            	<spring:message code="tooltip.maxSimultaneousTalkers" text="tooltip.maxSimultaneousTalkers" var="tooltipMaxSimultaneousTalkers" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltipMaxSimultaneousTalkers}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>

							</div>
							<div class="col-md-8">
							<form:select path="maxTalkers">
			                <c:forEach var="i" begin="1" end="${serverConfiguration.maxAvailableTalkers}" step="1">
			                  <form:option value="${i}">${i}</form:option>
			                </c:forEach>
			              </form:select>
			          </div>
			        </div>
			        <div class="form-group row">
			        	<div class="col-md-4">
				        	<span class="uportal-channel-strong"><spring:message code="maxCameras" text="maxCameras"/></span>
			            	<spring:message code="tooltip.maxCamera" text="tooltip.maxCamera" var="tooltipMaxCamera" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltipMaxCamera}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
						</div>
						<div class="col-md-8">
							<form:select path="maxCameras">
			                <c:forEach var="i" begin="1" end="${serverConfiguration.maxAvailableCameras}" step="1">
			                  <form:option value="${i}">${i}</form:option>
			                </c:forEach>
			              </form:select>
			          </div>
			        </div>
			        <div class="form-group row">
			        	<div class="col-md-4">
				        	<span class="uportal-channel-strong"><spring:message code="supervised" text="supervised"/></span>
			            	<spring:message code="tooltip.supervised" text="tooltip.supervised" var="tooltipSupervised" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltipSupervised}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
						</div>
						<div class="col-md-8">
							<form:checkbox path="mustBeSupervised"/>
						</div>
			        </div>
			        <div class="form-group row">
			        	<div class="col-md-4">
				        	<span class="uportal-channel-strong"><spring:message code="allPermissions" text="allPermissions"/></span>
			            	<spring:message code="tooltip.allPermissions" text="tooltip.allPermissions" var="tooltipAllPermissions" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltipAllPermissions}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
						</div>
						<div class="col-md-8">
							<form:checkbox path="permissionsOn"/>
						</div>
			        </div>
			        <div class="form-group row">
			        	<div class="col-md-4">
				        	<span class="uportal-channel-strong"><spring:message code="raiseHandOnEntry" text="raiseHandOnEntry"/></span>
			            	<spring:message code="tooltip.raiseHandOnEntry" text="tooltip.raiseHandOnEntry" var="tooltipRaiseHandOnEntry" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltipRaiseHandOnEntry}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
						</div>
						<div class="col-md-8">
							<form:checkbox path="raiseHandOnEnter"/>
						</div>
			        </div>
			        <div class="form-group row">
			        	<div class="col-md-4">
				        	<span class="uportal-channel-strong"><spring:message code="recordingMode" text="recordingMode"/></span>
			            	<spring:message code="tooltip.recordingMode" text="tooltip.recordingMode" var="tooltipRecordingMode" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltipRecordingMode}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
						</div>
						<div class="col-md-4">
							<form:select path="recordingMode" items="${recordingModes}" />
						</div>
			        </div>
			        <div class="form-group row">
			        	<div class="col-md-4">
				        	<span class="uportal-channel-strong"><spring:message code="hideNamesInRecordings" text="hideNamesInRecordings"/></span>
			            	<spring:message code="tooltip.hideNamesInRecordings" text="tooltip.hideNamesInRecordings" var="tooltiphideNamesInRecordings" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltiphideNamesInRecordings}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
						</div>
						<div class="col-md-8">
							<form:checkbox path="hideParticipantNames"/>
						</div>
			        </div>
			        <div class="form-group row">
			        	<div class="col-md-4">
				        	<span class="uportal-channel-strong"><spring:message code="allowInSessionInvitations" text="allowInSessionInvitations"/></span>
			            	<spring:message code="tooltip.allowInSessionInvitations" text="tooltip.allowInSessionInvitations" var="tooltipallowInSessionInvitations" htmlEscape="false" />
							&nbsp;<a href="#" title="${ tooltipallowInSessionInvitations}" class="${n}toolTip"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a>
						</div>
						<div class="col-md-8"
							<form:checkbox path="allowInSessionInvites"/>
						</div>
			        </div>
			        </c:when>
		          <c:otherwise>
			          <form:hidden path="maxTalkers"/>
			          <form:hidden path="maxCameras"/>
			          <form:hidden path="mustBeSupervised"/>
			          <form:hidden path="permissionsOn"/>
			          <form:hidden path="raiseHandOnEnter"/>
			          <form:hidden path="recordingMode"/>
			          <form:hidden path="hideParticipantNames"/>
			          <form:hidden path="allowInSessionInvites"/>
			        </c:otherwise>
			      </c:choose>
			      <div class="form-group">
			      	<spring:message code="saveSession" var="saveSession" text="saveSession"/>
                  <input class="btn btn-success uportal-button" value="${saveSession}" type="submit">
                  <portlet:renderURL var="cancelAction" portletMode="VIEW" windowState="${windowState}"/>
                  <a href="${cancelAction}" class="btn btn-default uportal-button"><spring:message code="cancel" text="cancel"/></a>
			      </div>
		  </div>
  </spring:nestedPath>
</form>

<script type="text/javascript">
    <rs:compressJs>
    (function($) {
    	$(document).ready(function() {
    		//$("#${n}startdatepicker").datepicker();
    		//$("#${n}enddatepicker").datepicker();
    		$( "#${n}accordion" ).accordion({
    		      collapsible: true,
    		      heightStyle: "content",
    		      autoHeight: false,
    		      active: false
    		});
    		blackboardPortlet.showTooltip('.${n}toolTip');
    		
    		/* $("#${n}startHourMinute").timepicker({
    			step : 15,
    			timeFormat : 'H:i'
    		});
    		$("#${n}endHourMinute").timepicker(); */

    	});
    })(blackboardPortlet.jQuery);
    </rs:compressJs>
</script>
</div>
</div>
