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
<portlet:renderURL var="createSessionUrl" portletMode="EDIT" windowState="${windowState}" />
<c:if test="${!empty prefs['helpUrl'][0]}">
  <div class="help-link"><a href="${prefs['helpUrl'][0]}" target="_blank" class="btn btn-outline uportal-button"><spring:message code="help" text="help"/></a></div>
</c:if>
<div id="${n}tabs" class="dl-tabs ui-tabs ui-widget ui-widget-content ui-corner-all inner-nav-container">
  <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all inner-nav">
    <li class="ui-state-default ui-corner-top"><a href="#${n}tabs-1">Scheduled sessions</a></li>
    <li class="ui-state-default ui-corner-top"><a href="#${n}tabs-2">Past sessions</a></li>
  </ul>
<div id="${n}tabs-1">
<portlet:actionURL portletMode="EDIT" var="deleteSessionActionUrl">
  <portlet:param name="action" value="deleteSessions" />
</portlet:actionURL>
<form name="deleteSessions" action="${deleteSessionActionUrl}" method="post">
	<c:choose>
    <c:when test="${fn:length(upcomingSessions) gt 0}">
      <table width="100%" id="sessionList">
        <thead>
          <tr class="uportal-channel-table-header">
            <th class="dt" style="width: 1em;"><input id="${n}selectAllSessions-new" value="selectAllSessions" name="selectAllSessions" type="checkbox" /></th>
            <th class="dt" ><spring:message code="sessionName" text="sessionName"/></th>
            <th class="dt" ><spring:message code="startDateAndTime" text="startDateAndTime"/></th>
            <th class="dt" ><spring:message code="endDateAndTime" text="endDateAndTime"/></th>
                        <spring:message code="statusText" text="statusText" var="statusText" htmlEscape="false" />
            <th class="dt" style="width: 20em;" id="${n}statusToolTip"><spring:message code="status" text="status"/>&nbsp;<a href="#" title="${ statusText}" class="${n}statusLink"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a></th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
      <table>
	      <tr  width="100%" >
		      <td align="left">
		            <spring:message code="deleteSession" var="deleteSession" text="deleteSession"/>
		            <spring:message code="areYouSureYouWantToDeleteSession" var="areYouSureYouWantToDeleteSession" text="areYouSureYouWantToDeleteSession"/>
		          <input id="dialog-confirm" value="${deleteSession}" name="Delete"
		            style="text-transform: none;" class="btn btn-default uportal-button"
		            onclick="javascript:return confirm('${areYouSureYouWantToDeleteSession}');"
		            type="submit" />
		            <c:if test="${!empty deleteSessionError}">
		                <span class="error">${deleteSessionError}</span>
		            </c:if>
		        </td>
	      </tr>
      </table>
    </c:when>
    <c:otherwise>
      <div class="centered-content">
        <h2 class="view-title">Schedule a web conference!</h2>
        <b>No sessions scheduled</b>
        <p><a href="${createSessionUrl }" id="create-user" class="btn btn-flat uportal-button"><spring:message code="scheduleWebConferencingSession" text="scheduleWebConferencingSession"/></a></p>
        <p class="highlighted-link"><a href="#${n}tabs-2">See past web conference sessions</a></p>
      </div>
    </c:otherwise>
  </c:choose>
</form>
</div>
<div id="${n}tabs-2">
<!-- completedSessionList -->
<form name="deleteSessions" action="${deleteSessionActionUrl}" method="post">
	<c:choose>
    <c:when test="${fn:length(completedSessions) gt 0}">
      <table width="100%" id="completedSessionList">
        <thead>
          <tr class="uportal-channel-table-header">
            <th style="width: 1em;"><input id="${n}selectAllSessions-old" value="selectAllSessions" name="selectAllSessions" type="checkbox" /></th>
            <th><spring:message code="sessionName" text="sessionName"/></th>
            <th><spring:message code="startDateAndTime" text="startDateAndTime"/></th>
            <th><spring:message code="endDateAndTime" text="endDateAndTime"/></th>
            <spring:message code="statusText" text="statusText" var="statusText" htmlEscape="false" />
            <th style="width: 20em;" id="${n}statusToolTip"><spring:message code="status" text="status"/>&nbsp;<a href="#" title="${ statusText}" class="${n}statusLink"><img src='<c:url value="/images/questionmark.jpg"/>' alt="?"/></a></th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
      <table>
	      <tr  width="100%" >
		      <td align="left">
		            <spring:message code="deleteSession" var="deleteSession" text="deleteSession"/>
		            <spring:message code="areYouSureYouWantToDeleteSession" var="areYouSureYouWantToDeleteSession" text="areYouSureYouWantToDeleteSession"/>
		          <input id="dialog-confirm" value="${deleteSession}" name="Delete"
		            style="text-transform: none;" class="btn btn-default uportal-button"
		            onclick="javascript:return confirm('${areYouSureYouWantToDeleteSession}');"
		            type="submit" />
		            <c:if test="${!empty deleteSessionError}">
		                <span class="error">${deleteSessionError}</span>
		            </c:if>
		        </td>
	      </tr>
      </table>
    </c:when>
    <c:otherwise>
      <b>There are no historical web conferences.</b>
    </c:otherwise>
  </c:choose>
</form>
</div>
</div>
<script type="text/javascript">
<rs:compressJs>
//begin javascript
(function($) {
blackboardPortlet.jQuery(function() {
  var $ = blackboardPortlet.jQuery;
  var currentWCPTab = "${n}"+"webConferencePortletTab";
  $("#${n}tabs").tabs(
		{
			create: function(event, ui){
				if(!sessionStorage.getItem(currentWCPTab)){
						sessionStorage.setItem(currentWCPTab, 0);
				}
				ui.tab.addClass('ui-tabs-selected');
			},
			active: sessionStorage.getItem(currentWCPTab),
			activate: function(event, ui){
					var currentTab = $("#${n}tabs").tabs("option", "active");
					sessionStorage.setItem(currentWCPTab, currentTab);
					
					//new styles :|
					ui.oldTab.removeClass('ui-tabs-selected');
					ui.newTab.addClass('ui-tabs-selected');
				}
		}	  
  );
  
  var upcomingSessions = 
	  <json:array var="session" items="${upcomingSessions}" prettyPrint="true" escapeXml="false">
	    <json:array>
	    <portlet:renderURL var="viewSessionUrl" windowState="${windowState}">
	     <portlet:param name="sessionId" value="${session.sessionId}" />
	     <portlet:param name="action" value="viewSession" />
	    </portlet:renderURL>
	    
	    <json:property name="deleteCheckbox">
	    <sec:authorize access="hasPermission(#session, 'delete')">
	        <input value='${session.sessionId}' class='${n}deleteSession-new' name='deleteSession' type='checkbox' />
	    </sec:authorize>
	    </json:property>
	    <json:property name="sessionName">
	  	  <a href='${viewSessionUrl}'>${session.sessionName}</a>
	    </json:property>
	    <json:property name="startTime">
	      <joda:format value="${session.startTime}" pattern="MM/dd/yyyy HH:mm z" />
	    </json:property>
	    <json:property name="endTime">
	      <joda:format value="${session.endTime}" pattern="MM/dd/yyyy HH:mm z" />
	    </json:property>
	    <json:property name="join">
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
	    </json:property>
	    </json:array>
	  </json:array>
	  
	  var completedSessions = 
		  <json:array var="completedSessions" items="${completedSessions}" prettyPrint="true" escapeXml="false">
		    <json:array>
		    <portlet:renderURL var="viewSessionUrl" windowState="${windowState}">
		     <portlet:param name="sessionId" value="${completedSessions.sessionId}" />
		     <portlet:param name="action" value="viewSession" />
		    </portlet:renderURL>
		    
		    <json:property name="deleteCheckbox">
		    <sec:authorize access="hasPermission(#completedSessions, 'delete')">
		        <input value='${completedSessions.sessionId}' class='${n}deleteSession-old' name='deleteSession' type='checkbox' />
		    </sec:authorize>
		    </json:property>
		    <json:property name="sessionName">
		  	  <a href='${viewSessionUrl}'>${completedSessions.sessionName}</a>
		    </json:property>
		    <json:property name="startTime">
		      <joda:format value="${completedSessions.startTime}" pattern="MM/dd/yyyy HH:mm z" />
		    </json:property>
		    <json:property name="endTime">
		      <joda:format value="${completedSessions.endTime}" pattern="MM/dd/yyyy HH:mm z" />
		    </json:property>
		    <json:property name="join">
		     <c:choose>
		       <c:when test="${completedSessions.endTime.beforeNow}">
		         <spring:message code="sessionIsClosed" text="sessionIsClosed"/>
		       </c:when>
		       <c:otherwise>
		     	<c:choose>
		  	   <c:when test="${completedSessions.startTimeWithBoundaryTime.beforeNow}">
		  	      	<a href='${completedSessions.launchUrl}' target="_blank"><spring:message code="joinNow" text="joinNow"/></a>
		  	   </c:when>
		  	   <c:otherwise>
		  	    	${session.timeUntilJoin}
		  	   </c:otherwise>
		         </c:choose>
		       </c:otherwise>
		     </c:choose>
		    </json:property>
		    </json:array>
		  </json:array>

  $(document).ready(function() {
    $(document).on( 'init.dt', function ( e, settings ) {
      if(settings.sInstance === "sessionList") {
          $('#${n}blackboardCollaboratePortlet #${n}selectAllSessions-new').click(function() {
              $('#${n}blackboardCollaboratePortlet .${n}deleteSession-new').prop('checked', $(this).is(':checked'));
          });
          
          $('#${n}blackboardCollaboratePortlet .${n}deleteSession-new').click(function() {
              if (!$(this).is(':checked')) {
                $('#${n}blackboardCollaboratePortlet #${n}selectAllSessions-new').prop('checked', false);
              }
              else if ($('#${n}blackboardCollaboratePortlet .${n}deleteSession-new').not(':checked').length == 0) {
                $('#${n}blackboardCollaboratePortlet #${n}selectAllSessions-new').prop('checked', true);
              }
          });
      } else {
          $('#${n}blackboardCollaboratePortlet .${n}deleteSession-old').click(function() {
              if (!$(this).is(':checked')) {
                $('#${n}blackboardCollaboratePortlet #${n}selectAllSessions-old').prop('checked', false);
              }
              else if ($('#${n}blackboardCollaboratePortlet .${n}deleteSession-old').not(':checked').length == 0) {
                $('#${n}blackboardCollaboratePortlet #${n}selectAllSessions-old').prop('checked', true);
              }
          });
          
          $('#${n}blackboardCollaboratePortlet #${n}selectAllSessions-old').click(function() {
              $('#${n}blackboardCollaboratePortlet .${n}deleteSession-old').prop('checked', $(this).is(':checked'));
          });
      }
    } );
    
    var futureTable = $('#sessionList').dataTable( {
    		"aaData": upcomingSessions,
    		"aaSorting": [[3, "desc"]],
    		"bAutoWidth" : false,
    		"bDeferRender": true,
    		"sPaginationType": "full_numbers",
    		"aoColumns": [{ "bSortable": false },
    		              null,
    		              null,
    		              null,
    		              null
    		              ]
    		} );
    var pastTable = $('#completedSessionList').dataTable( {
            "aaData": completedSessions,
            "aaSorting": [[3, "desc"]],
            "bAutoWidth" : false,
            "bDeferRender": true,
            "sPaginationType": "full_numbers",
            "aoColumns": [{ "bSortable": false },
                          null,
                          null,
                          null,
                          null
                          ]
        });
      
    blackboardPortlet.showTooltip('.${n}statusLink');
  });
});
})(blackboardPortlet.jQuery);
</rs:compressJs>
</script>
</div>
</div>