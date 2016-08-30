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

<%@ include file="/WEB-INF/jsp/include.jsp"%>
<%@ include file="/WEB-INF/jsp/header.jsp"%>
<portlet:renderURL var="backUrl" portletMode="VIEW" />
<portlet:renderURL var="createSessionUrl" portletMode="EDIT" windowState="${windowState}" />
<div id="${n}blackboardCollaboratePortlet" class="blackboardVCRoot">
<c:if test="${!empty prefs['helpUrl'][0]}">
    <div class="help-link">
      <a href="${backUrl}" class="btn btn-default btn-back uportal-button"><< Back to Session List</a>
    <a href="${createSessionUrl }" id="create-user" class="btn btn-small-blue uportal-button"><spring:message code="scheduleWebConferencingSession" text="scheduleWebConferencingSession"/></a>
    <a href="${prefs['helpUrl'][0]}" target="_blank" class="btn btn-default uportal-button"><spring:message code="help" text="help"/></a>
    </div>
</c:if>

<portlet:renderURL var="viewSessionUrl" windowState="${windowState}" portletMode="VIEW">
   <portlet:param name="sessionId" value="${session.sessionId}" />
   <portlet:param name="action" value="viewSession" />
</portlet:renderURL>

<div class="error">
<span class="uportal-channel-strong">${multimediaUploadError}</span>
</div>






<div class="viewSession">
  <div class="row">
    <div class="col-md-12">
      <div class="session-large-heading"><a href="${viewSessionUrl}">${session.sessionName}</a></div>
      </div>
    </div>
</div>

<div class="viewSession">
  <div class="session-medium-heading">Upload / Edit Media Files</div>
  <p class="session-descriptive-text">You may upload most common video formats, including .mpeg, .mpg, .mpe, .mov, .qt, .swf, .m4v, .mp3, .mp4, .wmv.</p>
      
</div>

<table class="mediaFileList">
    <tr>
      <td style="text-align: left;"><span class="uportal-channel-strong">Select</span></td><td style="text-align: left;"><span class="uportal-channel-strong">Media Files</span></td>
    </tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
    <tr>
      <td></td>
      <td>
        <portlet:actionURL portletMode="EDIT" var="uploadMediaFileActionUrl" name="uploadMediaFile">
          <portlet:param name="sessionId" value="${session.sessionId}" />
        </portlet:actionURL>
        <form action="${uploadMediaFileActionUrl}" method="post" enctype="multipart/form-data">
          <div class="ajaxerror file"></div>
          <div>
            <input name="multimediaUpload" size="40" type="file" accept="${multimediaFileTypes}"> 
          </div>
          <div>Accepted file formats: .mpeg, .mpg, .mpe, .mov, .qt, .swf, .m4v, .mp3, .mp4, mpeg, .wmv</div>
          <button class="btn btn-default uportal-button" name="uploadFile" type="submit">Upload File</button>
        </form>
      </td>
    </tr>
    <tr>
      <td align="left"><button name="deleteSelected" class="btn btn-default uportal-button">Delete</button></td>
      <td></td>
    </tr>
    <tr>
      <td colspan="2" align="left"><a href="${viewSessionUrl}" class="btn btn-success uportal-button">&lt; Save Media</a></td>
    </tr>
  </tfoot>
</table>

<portlet:resourceURL var="getMediaFilesUrl" id="getMediaFiles" escapeXml="false" />
<portlet:resourceURL var="deleteMediaFileUrl" id="deleteMediaFile" escapeXml="false" />

<script id="${n}mediFileTemplate" type="text/template">
  <td><input name="file_select" type="checkbox" value="{{= cid }}"/></td>
  <td>{{=name}}</td>
</script>

<script type="text/javascript">
(function($, Backbone, _) {
   'use strict';

   blackboardPortlet.initMediaFileBackbone({
      getMediaFilesUrl: "${getMediaFilesUrl}",
      deleteMediaFileUrl: "${deleteMediaFileUrl}",
      sessionId : '${session.sessionId}',
      mediaFileTemplateSelector: '#${n}mediFileTemplate',
      mediaFilesViewSelector: "div#${n}blackboardCollaboratePortlet table.mediaFileList"
   });

	$(document).ready(function() {
		blackboardPortlet.showTooltip('.${n}toolTip');
	});
})(blackboardPortlet.jQuery);

</script>
</div>
