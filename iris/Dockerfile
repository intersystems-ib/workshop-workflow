ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-cd
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown -R irisowner:irisowner /opt/irisapp

USER irisowner

# copy files to image
WORKDIR /opt/irisapp
COPY --chown=irisowner:irisowner src src
 
COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/irissession.sh /
RUN chmod +x /irissession.sh

COPY --chown=$ISC_PACKAGE_MGRUSER:$ISC_PACKAGE_IRISGROUP /iris/webapp.xml /
RUN chmod +x /webapp.xml

SHELL ["/irissession.sh"]

RUN \
zn "%SYS" \
do ##class(SYS.Container).QuiesceForBundling() \
do ##class(Security.Users).UnExpireUserPasswords("*")

RUN \
zn "HSLIB" \
Do ##class(HS.Util.Installer.Foundation).Install("WORKFLOW") \
zn "WORKFLOW" \
Do ##class(EnsLib.Workflow.RoleDefinition).CreateRole("ManualBloodPressureRole") \
Do ##class(EnsLib.Workflow.RoleDefinition).CreateRole("AutomaticBloodPressureRole") \
set sc = $SYSTEM.OBJ.LoadDir("/opt/irisapp/src/Workflow", "ck", , 1) \
do ##class(Workflow.Utils.Functions).UserExists("FakeDoctor","ManualBloodPressureRole") \
# start production
set production = "Workflow.Production" \
set ^Ens.Configuration("csp","LastProduction") = production \
do ##class(Ens.Director).SetAutoStart(production) \
zn "%SYS" \
do ##class(Security.Applications).Import("/webapp.xml",.n) \