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

import com.elluminate.sas.BasicAuth;
import com.elluminate.sas.GetServerQuotasResponseCollection;
import com.elluminate.sas.ServerQuotas;
import com.elluminate.sas.ServerQuotasResponse;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jasig.portlet.blackboardvcportlet.dao.ServerQuotaDao;
import org.jasig.portlet.blackboardvcportlet.data.ServerQuota;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.ws.client.core.WebServiceTemplate;
import javax.portlet.PortletPreferences;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Service class for Server Quota
 * @author rgood
 */
@Service
public class ServerQuotaService {
    protected final Log logger = LogFactory.getLog(ServerQuotaService.class);
    
    private boolean isInit=false;
    private BasicAuth user;
    
    @Autowired
    private ServerQuotaDao serverQuotaDao;

	@Autowired
	private WebServiceTemplate webServiceTemplate;
    
    /**
     * Gets the Server quota
     * @return 
     */
     public ServerQuota getServerQuota()
     {
         return this.serverQuotaDao.getServerQuota();
     }
    
     /**
      * Refresh the server quota, only goes to Collaborate if last update
      * was longer than an hour ago.
      * @param prefs PortletPreferences
      */
    public void refreshServerQuota(PortletPreferences prefs)
    {
        // Quota will refresh on the hour
        ServerQuota serverQuota = serverQuotaDao.getServerQuota();
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.HOUR_OF_DAY,-1);
        Date date = calendar.getTime();

		if (serverQuota == null || serverQuota.getLastUpdated().before(date))
		{
			logger.debug("Quota being refreshed");
			if (!this.isInit())
				doInit(prefs);

			try
			{
				// Call Web Service Operation
				GetServerQuotasResponseCollection serverQuotasResponseCollection = (GetServerQuotasResponseCollection) webServiceTemplate.marshalSendAndReceive(new ServerQuotas());
				List<ServerQuotasResponse> quotaResult = serverQuotasResponseCollection.getServerQuotasResponses();
				this.logger.debug("Result = " + quotaResult);
				for (ServerQuotasResponse response : quotaResult)
				{
					ServerQuota quota = new ServerQuota();
					quota.setDiskQuota(response.getDiskQuota());
					quota.setDiskQuotaAvailable(response.getDiskQuotaAvailable());
					quota.setSessionQuota(response.getSessionQuota());
					quota.setSessionQuotaAvailable(response.getSessionQuotaAvailable());
					quota.setLastUpdated(new Date());
					this.logger.debug("disk quota:" + quota.getDiskQuota());
					this.logger.debug("disk quota available:" + quota.getDiskQuotaAvailable());
					this.logger.debug("session quota:" + quota.getSessionQuota());
					this.logger.debug("session quota available:" + quota.getSessionQuotaAvailable());

					//ServerQuotaService serviceQuotaImpl = new ServerQuotaService();
					/// serviceQuotaImpl.saveServerQuota(quota);
					serverQuotaDao.deleteServerQuota();
					serverQuotaDao.saveServerQuota(quota);
				}
			}
			catch (Exception ex)
			{
				this.logger.error(ex.toString());
			}
		} else
		{
			logger.debug("Quota doesn't need refreshed");
		}
	}
    
    private boolean isInit()
    {
        return this.isInit;
    }
    
    /**
     * Init method for Basic Auth user
     * @param prefs PortletPreferences
     */
    private void doInit(PortletPreferences prefs)
    {
        logger.debug("doInit called");
        user = new BasicAuth();
        user.setName(prefs.getValue("wsusername",null));
        user.setPassword(prefs.getValue("wspassword",null));
    }
    
    
}
