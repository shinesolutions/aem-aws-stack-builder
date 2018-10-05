#!/bin/bash
#
# This script supports the inplace upgrade to AEM64 on a consolidated
#
# Prerequisites Upgrade:
# * Place package pre-upgrade-tasks-content-cq62-1.2.4.zip in the defined s3 bucket
# * Place crx2oak jar file crx2oak-1.8.6-all-in-one.jar in the defined s3 bucket
#
# Prerequisites Post-Upgrade:
# * Place following packages in the defined s3 bucket:
# ** acs-aem-commons-content-3.17.4.zip
# ** acs-aem-tools-content-1.0.0.zip
# ** com.adobe.acs.bundles.netty-1.0.2.zip
#

current_datetime=$(date "+%Y-%m-%d-%H-%M-%S")
java_run=true

aem_workdir="/opt/aem"
author_workdir="${aem_workdir}/author"
author_crx_workdir="${author_workdir}/crx-quickstart"
shinesolutions_workdir="/opt/shinesolutions"
aemtools_workdir="${shinesolutions_workdir}/aem-tools"

# S3 Bucket
s3_bucket="aem-opencloud"
s3_bucket_path="s3://${s3_bucket}"

### Prerequisites Upgrade Parameters
# Log Purge rules
create_version_purge=true
create_workflow_purge=false
create_audit_purge=false

# Deletion of bak files older than x days
enable_delete_bak_files=true
bak_file_age=30

# Enable offline Snapshot
enable_offline_snapshot=false

# Definition of the crx2oak file to apply for repository migration
# This file must be located in the defined s3_bucket
crx2oak_source="${s3_bucket_path}/crx2oak-1.8.6-all-in-one.jar"

# Using ${aemtools_workdir}/deploy-artifact.sh to install pre upgrade task package
# Definition for the pre upgrade tasks package
pre_upgrade_package_source="${s3_bucket_path}/pre-upgrade-tasks-content-cq62-1.2.4.zip"
pre_upgrade_package_group="day/cq62/product"
pre_upgrade_package_name="pre-upgrade-tasks-content-cq62"
pre_upgrade_package_version="1.2.4"
pre_upgrade_package_replicate=false
pre_upgrade_package_activate=true
pre_upgrade_package_force=false

### Post Upgrade parameters starts from here
enable_post_upgrade=true
enable_stop_rewriter_bundle=false

# Parameters to install latest acs aem commons content package
acs_aem_commons_install=true
acs_aem_commons_source="${s3_bucket_path}/acs-aem-commons-content-3.17.4.zip"
acs_aem_commons_group="adobe/consulting"
acs_aem_commons_name="acs-aem-commons-content"
acs_aem_commons_version="3.17.4"
acs_aem_commons_replicate=false
acs_aem_commons_activate=true
acs_aem_commons_force=false

# Parameters to install latest acs aem tools content package
acs_aem_tools_install=true
acs_aem_tools_source="${s3_bucket_path}/acs-aem-tools-content-1.0.0.zip"
acs_aem_tools_group="adobe/consulting"
acs_aem_tools_name="acs-aem-tools-content"
acs_aem_tools_version="1.0.0"
acs_aem_tools_replicate=false
acs_aem_tools_activate=true
acs_aem_tools_force=false

# Parameters to install package com.adobe.acs.bundles.netty
acs_bundles_netty_install=true
acs_bundles_netty_source="${s3_bucket_path}/com.adobe.acs.bundles.netty-1.0.2.zip"
acs_bundles_netty_group="adobe/consulting"
acs_bundles_netty_name="com.adobe.acs.bundles.netty"
acs_bundles_netty_version="1.0.2"
acs_bundles_netty_replicate=false
acs_bundles_netty_activate=true
acs_bundles_netty_force=false

translate_exit_code() {

  exit_code="$1"
  if [ "$exit_code" -eq 0 ]; then
    exit_code=0
  else
    exit "$exit_code"
  fi

  return "$exit_code"
}

start_author_plain () {
    cd ${author_workdir}
    java -Xmx4096m -jar aem-author-4502.jar > /dev/null 2>&1 &
    echo $!
}

start_aem_author() {
    echo "Starting Author instance"
    cd ${author_workdir}
    systemctl start aem-author
    translate_exit_code "$?"
}

stop_aem_author() {
    echo "Stopping Author instance"
    cd ${author_workdir}
    systemctl stop aem-author
    translate_exit_code "$?"
}

restart_aem_author() {
  stop_aem_author
  java_run=true
  wait_author_stopped
  start_aem_author
  java_run=false
  wait_author_started
}

wait_author_started () {
  while [ $java_run == 'false' ] || [ $java_run == 'False' ] ; do
    if (( $(ps -ef | grep -v grep | grep java | grep author | wc -l) > 0 )); then
      echo "Author instance is started."
      java_run=true
    else
      echo "Wait till Author instance is started."
      sleep 10
      java_run=false
    fi
  done
}

wait_author_stopped () {
  while [ $java_run == 'true' ] || [ $java_run == 'True' ] ; do
    if (( $(ps -ef | grep -v grep | grep java | grep author | wc -l) > 0 )); then
      echo "Wait till Author process is stopped"
      sleep 10
      java_run=true
    else
      echo "Author process is stopped"
      java_run=false
    fi
  done
}

update_author_permission () {
  echo "Update permissions to aem-author:aem-author for path ${author_workdir} & ${author_crx_workdir}/repository/"
  chown -R aem-author:aem-author /opt/aem/author
  chown -R aem-author:aem-author /opt/aem/author/crx-quickstart/repository/*
}

upgrade_author () {
  cd ${author_workdir}
  java -server -Xmx4096m -Dcom.adobe.upgrade.forcemigration=true \
  -Djava.awt.headless=true -Dsling.run.modes=author,crx3,crx3tar \
  -jar crx-quickstart/app/cq-quickstart-6.4.0-standalone-quickstart.jar start -c crx-quickstart -i launchpad \
  -p 4502 -Dsling.properties=crx-quickstart/conf/sling.properties  > /dev/null 2>&1 &
  echo $!
}

echo "Upgrading AEM to AEM 6.4"
echo "."
echo "Upgrade Steps:"
echo "1. Stopping Author instance"
echo "2. Start Author instance from jar file"
echo "3. Configure Audit purge log and workflow purge manually"
echo "4. Create Version Purge rule."
echo "5. Create workflow Purge rule."
echo "6. Create Audit Purge rule."
echo "7. Please run Version, Audit and workflow purge job manually"
echo "8. Please uninstall any existing acs-aem-common-content package manually"
echo "9. Run RevisionGarbageCollection"
echo "10. Disable Author replication agents manually"
echo "11. Install pre upgrade tasks for Author instance"
echo "12. Trigger run of all pre upgrade tasks for author instance"
echo "13. Check if pre upgrade tasks where successfully manually"
echo "14. Stop of Author process"
echo "15. Copy Files needed for Upgrading"
echo "16. Create Backup"
echo "17. Remopve old .bak files from repository"
echo "18. Run offline compaction job"
echo "19. Unpack AEM 64 jar file for Author"
echo "20. Run Repository migration for Author"
echo "21. Check logfiles for success of the repository upgrade"
echo "22. Run AEM Upgrade for Author"
echo "23. Check if AEM Upgrade for Author was successful manually"
echo "24. Stop Author instance"
echo "25. Run Post-Upgrade jobs"
echo "25.1 Start AEM Author"
echo "25.2 Check if AEM successfully starts manually"
echo "25.3 Stop org.apache.sling.rewriter bundle"
echo "25.4 Install ACS Bundles netty"
echo "25.5 Install ACS AEM Tools"
echo "25.6 Install ACS AEM Comons Content"
echo "25.7 Stop AEM Author"
echo "26. Run offline Snapshot "
read -p "Press enter to start AEM Upgrade process"
echo "."
echo "."
stop_aem_author
echo "."
echo "."
java_run=true
wait_author_stopped
echo "."
echo "."
echo "Starting Author instance without any options"
author_pid=$(start_author_plain)
java_run=false
wait_author_started
echo "."
echo "."
echo "Please configure Audit purge log and workflow purge manually"
echo "http://localhost:4502/system/console/configMgr"
read -p "Press enter to continue to create automated purge rules"
echo "."
echo "."
echo "Create Purge Rules"
if [ $create_version_purge == 'True' ] || [ $create_version_purge == 'true' ] ; then
  echo "."
  echo "."
  echo "Create Version Purge rule for Author."
  curl -f -u admin:admin \
   -F 'jcr:primaryType=nt:unstructured' \
   -F 'sling:resourceType=granite/operations/components/maintenance/task' \
   -F ':redirect=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_daily' \
   -F 'name=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_daily' \
   -F 'granite.task.disclaimer=' \
   -F 'granite.task.hint=' \
   -F 'granite.maintenance.name=com.day.cq.wcm.core.impl.VersionPurgeTask' \
   'http://localhost:4502/apps/granite/operations/config/maintenance/_granite_daily/*'
  translate_exit_code "$?"
  echo "Version Purge rule for Author created."
fi

if [ $create_workflow_purge == 'True' ] || [ $create_workflow_purge == 'true' ] ; then
  echo "."
  echo "."
  echo "Create workflow Purge rule for Author."
  curl -f -u admin:admin \
   -F 'jcr:primaryType=nt:unstructured' \
   -F 'sling:resourceType=granite/operations/components/maintenance/task' \
   -F ':redirect=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'name=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'granite.task.disclaimer=' \
   -F 'granite.maintenance.name=WorkflowPurgeTask' \
   'http://localhost:4502/apps/granite/operations/config/maintenance/_granite_weekly/*'
  translate_exit_code "$?"
  echo "workflow Purge rule for Author created."
fi

if [ $create_audit_purge == 'True' ] || [ $create_audit_purge == 'true' ] ; then
  echo "."
  echo "."
  echo "Create Audit Purge rule for Author."
  curl -f -u admin:admin \
   -F 'jcr:primaryType=nt:unstructured' \
   -F 'sling:resourceType=granite/operations/components/maintenance/task' \
   -F ':redirect=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'name=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'granite.task.hint=' \
   -F 'granite.maintenance.name=com.day.cq.audit.impl.AuditLogMaintenanceTask' \
   'http://localhost:4502/apps/granite/operations/config/maintenance/_granite_weekly/*'
  translate_exit_code "$?"
  echo "Audit Purge rule for Author created."
fi
echo "."
echo "."
echo "Please run Version, Audit and workflow purge job manually and wait till it's finished succesfully."
echo "http://localhost:4502/libs/granite/operations/content/maintenance.html"
read -p "Press enter to continue"
echo "."
echo "."
echo "Please uninstall any existing acs-aem-common-content package manually"
echo "http://localhost:4502/crx/packmgr/index.jsp"
read -p "Press enter to continue"
echo "."
echo "."
echo "Run RevisionGarbageCollection"
curl -f -u admin:admin \
  -X POST \
  "http://localhost:4502/system/console/jmx/org.apache.jackrabbit.oak:name=Segment+node+store+revision+garbage+collection,type=RevisionGarbageCollection/op/startRevisionGC/"
translate_exit_code "$?"
echo "."
echo "."
echo "Please check if RevisionGarbageCollection was succesfully manually"
echo "http://localhost:4502/system/console/jmx"
read -p "Press enter to continue"
echo "."
echo "."
echo "Please disable Author replication agents manually"
echo "http://localhost:4502/etc/replication/agents.author/replicationAgent-localhost.html"
read -p "Press enter to continue"
echo "."
echo "."
echo "Install pre upgrade tasks for Author instance from ${pre_upgrade_package_source}"
${aemtools_workdir}/deploy-artifact.sh author "${pre_upgrade_package_source}" ${pre_upgrade_package_group} ${pre_upgrade_package_name} ${pre_upgrade_package_version} ${pre_upgrade_package_replicate} ${pre_upgrade_package_activate} ${pre_upgrade_package_force}
translate_exit_code "$?"
echo "."
echo "."
echo "Trigger run of all pre upgrade tasks for author instance"
curl -f -v -u admin:admin -X POST 'http://localhost:4502/system/console/jmx/com.adobe.aem.upgrade.prechecks:type=PreUpgradeTasks/op/runAllPreUpgradeTasks/'
translate_exit_code "$?"
echo "."
echo "."
echo "Please check if pre upgrade tasks where successfully manually"
echo 'http://localhost:4502/system/console/jmx/com.adobe.aem.upgrade.prechecks:type=PreUpgradeTasks'
read -p "Press enter to continue"
echo "."
echo "."
echo "Please confirm to stop of Author process"
read -p "Press enter to continue"
kill ${author_pid}
echo "."
java_run=true
wait_author_stopped
echo "."
echo "."
echo "Copying AEM 6.4 Quickstart file to $author_workdir"
aws s3 cp ${s3_bucket_path}/AEM_6.4_Quickstart.jar $author_workdir/; \
echo "."
echo "."
echo "creating backup directory ${author_workdir}/backup"
if [ -d ${author_workdir}/backup ]; then
  mv ${author_workdir}/backup ${author_workdir}/backup_${current_datetime}
  mkdir ${author_workdir}/backup
else
  mkdir ${author_workdir}/backup
fi
echo "."
echo "."
if [ -f ${author_workdir}/AEM_6.2_Quickstart.jar ]; then
  echo "Move file ${author_workdir}/AEM_6.2_Quickstart.jar to ${author_workdir}/backup"
  mv ${author_workdir}/AEM_6.2_Quickstart.jar ${author_workdir}/backup/
fi
echo "."
echo "."
echo "."
if [ -f ${author_workdir}/aem-author-4502.jar ]; then
  echo "Move file ${author_workdir}/aem-author-4502.jar to ${author_workdir}/backup"
  mv ${author_workdir}/aem-author-4502.jar ${author_workdir}/backup/
fi
echo "."
echo "."
if [ -f ${author_workdir}/AEM_6.4_Quickstart.jar ]; then
  echo "Rename file ${author_workdir}/AEM_6.4_Quickstart.jar to ${author_workdir}/aem-author-4502.jar"
  mv ${author_workdir}/AEM_6.4_Quickstart.jar ${author_workdir}/aem-author-4502.jar
fi
echo "."
echo "."
echo "Adds execution right to file aem-author-4502.jar"
chmod +x ${author_workdir}/aem-author-4502.jar
echo "."
echo "."
echo "Create a backup of ${author_crx_workdir} in ${author_workdir}/backup/"
cp -r ${author_crx_workdir} ${author_workdir}/backup/
echo "."
echo "."
if [ $enable_delete_bak_files == 'True' ] || [ $enable_delete_bak_files == 'true' ] ; then
  echo "removing .bak files older than ${bak_file_age} days in author repository ${author_crx_workdir}/repository/"
  echo "."
  echo "."
  find ${author_crx_workdir}/repository/ \
    -name '*.bak' \
    -type f \
    -mtime +$bak_file_age \
    -exec rm -fv '{}' \;

  echo "Finish removing .bak files older than $bak_file_age days."
  echo "."
  echo "."
fi
echo "."
echo "."
update_author_permission
echo "."
echo "."
echo "Run offline compaction job"
${aemtools_workdir}/offline-compaction.sh >> /var/log/shinesolutions/upgrade_offline_compaction.log 2>&1
translate_exit_code "$?"
echo "Offline Compaction job done."
read -p "Press enter to continue"
echo "."
echo "."
echo "Unpack aem-author-4502.jar"
cd ${author_workdir}
java -Xmx4096m -jar aem-author-4502.jar -unpack
echo "Unpack aem-author-4502.jar done"
echo "."
echo "."
echo "Wait till unpacking of aem-author-4502.jar is done."
echo "Please confirm to go to the next step 'repository upgrade'"
read -p "Press enter to continue"
echo "."
echo "."
update_author_permission
echo "."
echo "."
echo "Remove old crx2oak jar file from ${author_crx_workdir}/opt/extensions/"
rm -fv ${author_crx_workdir}/opt/extensions/crx2oak*.jar
echo "."
echo "."
echo "Copy ${crx2oak_source} to ${author_crx_workdir}/opt/extensions/crx2oak.jar"
aws s3 cp ${crx2oak_source} ${author_crx_workdir}/opt/extensions/crx2oak.jar
echo "."
echo "."
echo "Run Repository migration for Author"
cd ${author_workdir}
java -Xmx4096m -jar aem-author-4502.jar -v -x crx2oak -xargs -- --load-profile segment-no-ds
echo "."
echo "."
echo "Wait till repo migration for Author is done."
update_author_permission
echo "."
echo "."
echo "Repo migration is done please press enter to print last 50 lines of ${author_crx_workdir}/logs/upgrade.log"
read -p "Press enter to continue"
tail -n 50 ${author_crx_workdir}/logs/upgrade.log
echo "."
echo "."
echo "Please check logfile ${author_crx_workdir}/logs/upgrade.log for errors."
echo "Please confirm to go to the next step 'AEM Upgrade'"
read -p "Press enter to continue"
echo "."
echo "."
if [ -f ${author_crx_workdir}/app/cq-quickstart-6.2.0-standalone-quickstart.jar ]; then
    echo "Copying AEM 6.2 Quickstart file from ${author_crx_workdir}/app/ to /tmp as it's not needed anymore."
    mv ${author_crx_workdir}/app/cq-quickstart-6.2.0-standalone-quickstart.jar /tmp
fi
echo "."
echo "."
echo "Run AEM Upgrade for Author"
author_pid=$(upgrade_author)
echo "."
echo "."
echo "Sleep 10 minutes, as update may take around 10 minutes."
sleep 600
echo "Press enter to print last 50 lines of ${author_crx_workdir}/logs/upgrade.log"
read -p "Press enter to continue"
tail -n 50 ${author_crx_workdir}/logs/upgrade.log
echo "."
echo "."
echo "Please check logfile ${author_crx_workdir}/logs/upgrade.log if upgrade is finished."
read -p "If upgrade is finished press enter to continue"
echo "Stop Author instance"
kill ${author_pid}
echo "."
echo "."
java_run=true
wait_author_stopped
update_author_permission
echo "."
echo "."
echo "AEM Upgrade is done!"
read -p "Press enter to continue with post upgrade steps."
echo "."
echo "."
if [ $enable_post_upgrade == 'True' ] || [ $enable_post_upgrade == 'true' ] ; then
  echo "Starting Post Upgrade process"
  read -p "press enter to continue"
  echo "."
  echo "."
  start_aem_author
  echo "."
  echo "."
  java_run=false
  wait_author_started
  echo "."
  echo "."
  echo "Please verify that AEM started successfully manually."
  read -p "press enter to continue"
  echo "."
  echo "."
  if [ $enable_stop_rewriter_bundle == 'True' ] || [ $enable_stop_rewriter_bundle == 'true' ] ; then
    echo "Stopping bundle org.apache.sling.rewriter on Author."
    curl -f -u admin:admin \
     -F action=start \
     http://localhost:4502/system/console/bundles/org.apache.sling.rewriter
    translate_exit_code "$?"
    echo "Bundle org.apache.sling.rewriter stopped"
    read -p "press enter to continue"
    echo "."
    echo "."
  fi
  if [ $acs_bundles_netty_install == 'True' ] || [ $acs_bundles_netty_install == 'true' ] ; then
    echo "Installing ACS Bundle netty"
    ${aemtools_workdir}/deploy-artifact.sh author "${acs_bundles_netty_source}" ${acs_bundles_netty_group} ${acs_bundles_netty_name} ${acs_bundles_netty_version} ${acs_bundles_netty_replicate} ${acs_bundles_netty_activate} ${acs_bundles_netty_force}
    translate_exit_code "$?"
    echo "."
    echo "."
  fi
  if [ $acs_aem_tools_install == 'True' ] || [ $acs_aem_tools_install == 'true' ] ; then
    echo "Installing ACS AEM Tools on Author"
    ${aemtools_workdir}/deploy-artifact.sh author "${acs_aem_tools_source}" ${acs_aem_tools_group} ${acs_aem_tools_name} ${acs_aem_tools_version} ${acs_aem_tools_replicate} ${acs_aem_tools_activate} ${acs_aem_tools_force}
    translate_exit_code "$?"
    echo "."
    echo "."
  fi
  if [ $acs_aem_commons_install == 'True' ] || [ $acs_aem_commons_install == 'true' ] ; then
    echo "Installing ACS AEM commons on Author"
    ${aemtools_workdir}/deploy-artifact.sh author "${acs_aem_commons_source}" ${acs_aem_commons_group} ${acs_aem_commons_name} ${acs_aem_commons_version} ${acs_aem_commons_replicate} ${acs_aem_commons_activate} ${acs_aem_commons_force}
    translate_exit_code "$?"
    echo "."
    echo "."
  fi
  read -p "press enter to stop Author instance."
  echo "."
  echo "."
  stop_aem_author
  echo "."
  echo "."
  java_run=true
  wait_author_stopped
  echo "."
  echo "."
  echo "Post-upgrade steps are finished"
  read -p "press enter to continue"
fi
if [ $enable_offline_snapshot == 'True' ] || [ $enable_offline_snapshot == 'true' ] ; then
  read -p "Please press enter to run offline snapshot."
  echo "."
  echo "."
  echo "Run offline snapshot"
  ${aemtools_workdir}/offline-snapshot-backup.sh
  translate_exit_code "$?"
  echo "Offline snapshot done."
fi
echo "."
echo "."
read -p "press enter to exit"
