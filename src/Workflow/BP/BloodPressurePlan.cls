/// 
Class Workflow.BP.BloodPressurePlan Extends Ens.BusinessProcessBPL
{

Storage Default
{
<Type>%Storage.Persistent</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response' height='2000' width='2000' >
<context>
<property name='username' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='obxCount' type='%Integer' initialexpression='0' instantiate='0' />
<property name='obxIndex' type='%Integer' initialexpression='1' instantiate='0' />
<property name='dyastolic' type='%Integer' initialexpression='0' instantiate='0' />
<property name='systolic' type='%Integer' initialexpression='0' instantiate='0' />
</context>
<sequence xend='200' yend='1200' >
<code name='Checking user' xpos='200' ypos='250' >
<![CDATA[ set context.username = request.GetValueAt("PID:3(1).1")
 do ##class(Workflow.Utils.Functions).UserExists(context.username,"ManualBloodPressureRole")
  do ##class(Workflow.Utils.Functions).UserExists(context.username,"AutomaticBloodPressureRole")]]>
</code>
<code name='Getting count of OBX' xpos='200' ypos='350' >
<![CDATA[ set context.obxCount = request.GetValueAt("OBX(*)")
 set context.obxIndex = 1]]>
</code>
<while name='Check OBX values' condition='context.obxCount &gt;= context.obxIndex' xpos='200' ypos='450' xend='200' yend='950' >
<if name='Check systolic' condition='request.GetValueAt("OBX("_context.obxIndex_"):ObservationIdentifier.Identifier") = "163030003" ' xpos='200' ypos='250' xend='200' yend='750' >
<true>
<assign name="Assign systolic value" property="context.systolic" value="request.GetValueAt(&quot;OBX(&quot;_context.obxIndex_&quot;):ObservationValue(1)&quot;)" action="set" xpos='200' ypos='400' />
</true>
<false>
<if name='Check dyastolic' condition='request.GetValueAt("OBX("_context.obxIndex_"):ObservationIdentifier.Identifier") = "163030004" ' xpos='470' ypos='400' xend='470' yend='650' >
<true>
<assign name="Assign dyastolic value" property="context.dyastolic" value="request.GetValueAt(&quot;OBX(&quot;_context.obxIndex_&quot;):ObservationValue(1)&quot;)" action="set" xpos='605' ypos='550' />
</true>
</if>
</false>
</if>
<assign name="Add index" property="context.obxIndex" value="context.obxIndex + 1" action="set" xpos='200' ypos='850' />
</while>
<if name='Check pressure' condition='context.systolic &gt; 140 || context.dyastolic &gt; 90' xpos='200' ypos='550' xend='200' yend='1000' >
<true>
<call name='Create manual task' target='ManualBloodPressureRole' async='1' xpos='335' ypos='700' >
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Accept&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;Attention! Your blood pressure (&quot;_context.systolic_&quot; - &quot;_context.dyastolic_&quot;) are over the limit 130 - 90&quot;" action="set" />
<assign property="callrequest.%UserName" value="context.username" action="set" />
<assign property="callrequest.%Subject" value="&quot;High blood pressure&quot;" action="set" />
<assign property="callrequest.%Priority" value="2" action="set" />
</request>
<response type='EnsLib.Workflow.TaskResponse' />
</call>
<call name='Create auto task' target='AutomaticBloodPressureRole' async='1' xpos='335' ypos='800' >
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Accept&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;This is a task generated after receive a HL7 &quot;_context.systolic" action="set" />
<assign property="callrequest.%UserName" value="context.username" action="set" />
<assign property="callrequest.%Subject" value="&quot;Task created by HL7&quot;" action="set" />
</request>
<response type='EnsLib.Workflow.TaskResponse' />
</call>
<sync name='Wait for tasks' calls='Create manual task,Create auto task' type='all' xpos='335' ypos='900' />
</true>
</if>
<trace name='Task finished' value='"Task finished"' xpos='200' ypos='1100' />
</sequence>
</process>
}

}
