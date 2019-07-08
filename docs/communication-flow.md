Communication Flow
------------------

The communication between components within AEM architecture is uses HTTPS by default, while still allowing HTTP to be available as an alternative. The intention is obviously to encourage users to use HTTPS for security reason.

<table>
<tr>
<td valign="top">
<img width="600" alt="AEM Full-Set Communication Flow Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/communication-flow-full-set.png"/>
</td>
<td valign="top">
<ol>
<li>
<strong>From Site Visitor to  Publish-Dispatcher ELB</strong>
<p>Site visitor can connect to Publish-Dispatcher ELB via HTTPS on port 443. Alternatively, HTTP on port 80 is also available.</p>
<p>However, most users often have a layer (e.g. CDN/routing) sitting in front of the AEM architecture, which connects to AEM Publish-Dispatcher ELB only via HTTPS.</p>
</li>
<li>
<strong>From Publish-Dispatcher ELB to Publish-Dispatcher EC2 instance</strong>
<p>Publish-Dispatcher ELB connects to Publish-Dispatcher EC2 instance via HTTPS on port 443, and HTTP on port 80.</p>
<p>Publish-Dispatcher ELB health monitoring checks Publish-Dispatcher EC2 instance only via HTTPS on port 443, at path <code>/system/health?tags=shallow</code> .</p>
</li>
<li>
<strong>From Publish-Dispatcher EC2 instance to Publish EC2 instance</strong>
<p>AEM Publish-Dispatcher is configured to point to AEM Publish as its farm's website render via HTTPS on port 5433 with <code>secure</code> setting enabled.</p>
<strong>From Publish EC2 instance to Publish-Dispatcher EC2 instance</strong>
<p>AEM Publish is configured with a flush agent that points to AEM Publish-Dispatcher via HTTPS on port 443.</p>
</li>
<li>
<strong>From Author-Primary EC2 instance to Publish EC2 instance</strong>
<p>AEM Author is configured with replication agent that points AEM Publish via HTTPS on port 5433.</p>
</li>
<li>
<strong>From Author-Primary EC2 instance to Author-Standby EC2 instance</strong>
<p>Author-Standby is configured with <code>primary.host</code> pointing to Author-Primary. Data synchronisation is run through port 8023, with <code>secure</code> option currently set to false.</p>
</li>
<li>
<strong>From Author ELB to Author-Primary EC2 instance</strong>
<p>Author ELB connects to Author-Primary EC2 instance via HTTPS on port 5432, and HTTP on port 4502.</p>
<p>Author ELB health monitoring checks Author-Primary EC2 instance only via HTTPS on port 5432, at path <code>/system/health?tags=shallow</code> .</p>
</li>
<li>
<strong>From Author-Dispatcher EC2 instance to Author ELB</strong>
<p>AEM Author-Dispatcher is configured to point to AEM Author ELB as its farm's website render via HTTPS on port 443 with <code>secure</code> setting enabled.</p>
</li>
<li>
<strong>From Author-Dispatcher ELB to Author-Dispatcher EC2 instance</strong>
<p>Author-Dispatcher ELB connects to Author-Dispatcher EC2 instance via HTTPS on port 443, and HTTP on port 80.</p>
<p>Author-Dispatcher ELB health monitoring checks Author-Dispatcher EC2 instance only via HTTPS on port 443, at path <code>/system/health?tags=shallow</code> .</p>
</li>
<li>
<strong>From Content Author to Author-Dispatcher ELB</strong>
<p>Site visitor can connect to Author-Dispatcher ELB via HTTPS on port 443. Alternatively, HTTP on port 80 is also available.</p>
<p>However, most users often have a layer (e.g. routing via a reverse proxy) sitting in front of the AEM architecture, which connects to AEM Author-Dispatcher ELB only via HTTPS.</p>
</li>
</ol>
</td>
</tr>
</table>
