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
package org.jasig.portlet.blackboardvcportlet.service;

import javax.portlet.PortletPreferences;

import org.springframework.stereotype.Service;

/**
 * Service class for Server Quota
 * @author rgood
 */
@Service
public interface ServerQuotaService
{
	 /**
	  * Refresh the server quota, only goes to Collaborate if last update
	  * was longer than an hour ago.
	  * @param prefs PortletPreferences
	  */
    public void refreshServerQuota(PortletPreferences prefs);
}