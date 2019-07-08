Communication Flow
------------------

The communication between components within AEM architecture is uses HTTPS by default, while still allowing HTTP to be available as an alternative. The intention is obviously to encourage users to use HTTPS for security reason.

<table>
<tr>
<td valign="top">
<img width="300" alt="AEM Full-Set Communication Flow Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/communication-flow-full-set.png"/>
</td>
<td valign="top">
<ol>
<li>
<strong>From Site Visitor to  Publish-Dispatcher ELB</strong>
<p>Site visitor can connect to Publish-Dispatcher ELB via HTTPS on port 443. Alternatively, HTTP on port 80 is also available.</p>
<p>However, most users often have a layer (e.g. CDN/routing) sitting in front of AEM architecture, which connects to AEM Publish-Dispatcher ELB via HTTPS only.</p>
</li>
<li>
<strong>From Publish-Dispatcher ELB to Publish-Dispatcher EC2 instance</strong>
<p></p>
</li>
<li>
<strong>From Publish-Dispatcher EC2 instance to Publish EC2 instance</strong>
<p>TODO</p>
<strong>From Publish EC2 instance to Publish-Dispatcher EC2 instance</strong>
<p>TODO</p>
</li>
<li>
<strong>From Author-Primary EC2 instance to Publish EC2 instance</strong>
<p>TODO</p>
</li>
<li>
<strong>From Author-Primary EC2 instance to Author-Standby EC2 instance</strong>
<p>TODO</p>
</li>
<li>
<strong>From Author ELB to Author-Primary EC2 instance</strong>
<p>TODO</p>
</li>
<li>
<strong>From Author-Dispatcher EC2 instance to Author ELB</strong>
<p>TODO</p>
</li>
<li>
<strong>From Author-Dispatcher ELB to Author-Dispatcher EC2 instance</strong>
<p>TODO</p>
</li>
<li>
<strong>From Content Author to Author-Dispatcher ELB</strong>
<p>TODO</p>
</li>
</ol>
</td>
</tr>
</table>
