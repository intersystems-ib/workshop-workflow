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
<property name='automaticTask' type='EnsLib.Workflow.TaskResponse' instantiate='0' />
</context>
<sequence xend='200' yend='1650' >
<code name='Checking user' xpos='200' ypos='250' >
<![CDATA[ set context.username = request.GetValueAt("PID:3(1).1")
 do ##class(Workflow.Utils.Functions).UserExists(context.username,"ManualBloodPressureRole")
 do ##class(Workflow.Utils.Functions).UserExists(context.username,"AutomaticBloodPressureRole")]]>
</code>
<code name='Get automatic task' xpos='197' ypos='297' >
<![CDATA[  set sc = ##class(Workflow.Utils.Functions).CheckTask(context.username,"AutomaticBloodPressureRole", context.automaticTask)]]>
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
<if name='Check dyastolic' condition='request.GetValueAt("OBX("_context.obxIndex_"):ObservationIdentifier.Identifier") = "163031004" ' xpos='470' ypos='400' xend='470' yend='650' >
<true>
<assign name="Assign dyastolic value" property="context.dyastolic" value="request.GetValueAt(&quot;OBX(&quot;_context.obxIndex_&quot;):ObservationValue(1)&quot;)" action="set" xpos='605' ypos='550' />
</true>
</if>
</false>
</if>
<assign name="Add index" property="context.obxIndex" value="context.obxIndex + 1" action="set" xpos='200' ypos='850' />
</while>
<if name='Pending task?' condition='$ISOBJECT(context.automaticTask)' xpos='200' ypos='550' xend='200' yend='1450' >
<true>
<trace name='Pending task' value='"Pending task "_context.systolic_" "_context.dyastolic' xpos='740' ypos='700' />
<code name='Close automatic task' xpos='740' ypos='800' >
<![CDATA[ do context.automaticTask.CompleteTask("Accept")]]>
</code>
<if name='Check pressure' condition='context.systolic &gt; 140 || context.dyastolic &gt; 90' xpos='740' ypos='900' xend='740' yend='1350' >
<true>
<call name='Warning task for doctor' target='ManualBloodPressureRole' async='1' xpos='875' ypos='1050' >
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Accept&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;Attention! Your patient &quot;_context.username_&quot; has dangerous blood pressure levels!&quot;" action="set" />
<assign property="callrequest.%UserName" value="&quot;FakeDoctor&quot;" action="set" />
<assign property="callrequest.%Subject" value="&quot;High blood pressure&quot;" action="set" />
<assign property="callrequest.%Priority" value="1" action="set" />
</request>
<response type='EnsLib.Workflow.TaskResponse' />
</call>
<call name='Warning task for patient' target='ManualBloodPressureRole' async='1' xpos='875' ypos='1150' >
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Accept&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;Attention! Your blood pressure (&quot;_context.systolic_&quot; - &quot;_context.dyastolic_&quot;) are over the limit 130 - 90. Your doctor will contact you.&quot;" action="set" />
<assign property="callrequest.%UserName" value="context.username" action="set" />
<assign property="callrequest.%Subject" value="&quot;High blood pressure&quot;" action="set" />
<assign property="callrequest.%Priority" value="1" action="set" />
</request>
<response type='EnsLib.Workflow.TaskResponse' />
</call>
<sync calls='Warning task for doctor,Warning task for patient' type='all' xpos='875' ypos='1250' />
</true>
</if>
</true>
<false>
<trace name='No pending task' value='"No pending task "_context.systolic_" "_context.dyastolic' xpos='200' ypos='700' />
<if name='Check pressure' condition='(context.systolic &gt; 140) || (context.dyastolic &gt; 90)' xpos='200' ypos='800' xend='200' yend='1250' >
<true>
<call name='Create manual task' target='ManualBloodPressureRole' async='1' xpos='335' ypos='950' >
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Accept&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;Attention! Your blood pressure (&quot;_context.systolic_&quot; - &quot;_context.dyastolic_&quot;) are over the limit 130 - 90&quot;" action="set" />
<assign property="callrequest.%UserName" value="context.username" action="set" />
<assign property="callrequest.%Subject" value="&quot;High blood pressure&quot;" action="set" />
<assign property="callrequest.%Priority" value="2" action="set" />
</request>
<response type='EnsLib.Workflow.TaskResponse' />
</call>
<call name='Create auto task' target='AutomaticBloodPressureRole' async='1' xpos='335' ypos='1050' >
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Automatic&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;This is an automatic task to manage the info sent by devices&quot;" action="set" />
<assign property="callrequest.%UserName" value="context.username" action="set" />
<assign property="callrequest.%Subject" value="&quot;Waiting for blood pressure measures&quot;" action="set" />
</request>
<response type='EnsLib.Workflow.TaskResponse' />
</call>
<sync name='Wait for tasks' calls='Create manual task,Create auto task' type='all' xpos='335' ypos='1150' />
</true>
</if>
</false>
</if>
<trace name='Task finished' value='"Task finished"' xpos='200' ypos='1550' />
</sequence>
</process>
}

}
