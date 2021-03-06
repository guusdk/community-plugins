<%--
  -	$Revision$
  -	$Date$
  -
  - Copyright (C) 2004-2008 Jive Software. All rights reserved.
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
--%>

<%@ page import="org.jivesoftware.util.*,
                 java.util.*,
                 org.freeswitch.esl.client.transport.message.EslMessage,                 
                 java.net.URLEncoder"                 
    errorPage="error.jsp"
%>
<%@ page import="org.xmpp.packet.JID" %>
<%@ page import="org.dom4j.*" %>
<%@ page import="org.jivesoftware.openfire.plugin.ofswitch.OfSwitchPlugin" %>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>
<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager"  />
<% webManager.init(request, response, session, application, out ); %>
<%
	String xml = "";	
	int lines = 0;
	Document document = null;
	
	if (OfSwitchPlugin.self != null)
	{
		EslMessage resp = OfSwitchPlugin.self.sendFWCommand("conference xml_list");
		
		if (resp != null)
		{
			List<String> conferenceLines = resp.getBodyLines();
			

			for (String line : conferenceLines) 
			{
				xml = xml + line;
			}

			document = DocumentHelper.parseText(xml);
			Element result = document.getRootElement();

			Iterator conferences = result.elementIterator("conference");
			int count = 0;

			while (conferences.hasNext()) 
			{
				Element conference = (Element) conferences.next(); 		
				lines++;
			}
		}
	}
%>
<html>
<head>
<title>FreeSwitch Conferences</title>
<meta name="pageID" content="freeswitch-conferences"/>
</head>
<body>
<p>FreeSwitch Conferences</p>
<div class="jive-table">
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<thead>
    <tr>
        <th>Conference Id</th>
        <th nowrap>Member Count</th>           
        <th nowrap>Rate</th>
        <th nowrap>Running</th>         
    </tr>
</thead>
<tbody>

<% 
    	if (lines == 0) {
%>
    <tr>
        <td align="center" colspan="10">
            There are no active conferences
        </td>
    </tr>

<%
    	}
		
	if (document != null)
	{		
		Element result = document.getRootElement();

		Iterator conferences = result.elementIterator("conference");
		int count = 0;

		while (conferences.hasNext()) 
		{
			Element conference = (Element) conferences.next(); 

			String uuid = conference.attributeValue("uuid");
			String members = conference.attributeValue("member-count");
			String rate = conference.attributeValue("rate");
			String running = conference.attributeValue("running");	
%>
			<tr class="jive-<%= (((count%2)==0) ? "even" : "odd") %>">
			<td width="30%">
			    <%= uuid %>
			</td>
			<td width="10%" align="center">
				<%= members %>
			</td>
			<td width="30%" align="center">
				<%= rate %>           
			</td>
			<td width="30%" align="center">
				<%= running %>           
			</td>	
			</tr>
<%
			count++;
		}
	}
%>
</tbody>
</table>
</div>
</body>
</html>
