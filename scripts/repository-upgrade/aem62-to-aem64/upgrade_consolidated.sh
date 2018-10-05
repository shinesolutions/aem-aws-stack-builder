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
publish_workdir="${aem_workdir}/publish"
author_crx_workdir="${author_workdir}/crx-quickstart"
publish_crx_workdir="${publish_workdir}/crx-quickstart"
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

start_publish_plain () {
    cd ${publish_workdir}
    java -Xmx4096m -jar aem-publish-4503.jar > /dev/null 2>&1 &
    echo $!
}

start_aem_author() {
    echo "Starting Author instance"
    cd ${author_workdir}
    systemctl start aem-author
    translate_exit_code "$?"
}

start_aem_publish() {
    echo "Starting Publish instance"
    cd ${publish_workdir}
    systemctl start aem-publish
    translate_exit_code "$?"
}

stop_aem_author() {
    echo "Stopping Author instance"
    cd ${author_workdir}
    systemctl stop aem-author
    translate_exit_code "$?"
}

stop_aem_publish() {
  echo "Stopping Publish instance"
  cd ${publish_workdir}
  systemctl stop aem-publish
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

restart_aem_publish() {
  stop_aem_publish
  java_run=true
  wait_publish_stopped
  start_aem_publish
  java_run=false
  wait_publish_started
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

wait_publish_started () {
  while [ $java_run == 'false' ] || [ $java_run == 'False' ] ; do
    if (( $(ps -ef | grep -v grep | grep java | grep publish | wc -l) > 0 )); then
      echo "Publish instance is started"
      java_run=true
    else
      echo "Wait till Publish instance is started."
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

wait_publish_stopped () {
  while [ $java_run == 'true' ] || [ $java_run == 'True' ] ; do
    if (( $(ps -ef | grep -v grep | grep java | grep publish | wc -l) > 0 )); then
      echo "Wait till Publish process is stopped"
      sleep 10
      java_run=true
    else
      echo "Publish process is stopped"
      java_run=false
    fi
  done
}

update_author_permission () {
  echo "Update permissions to aem-author:aem-author for path ${author_workdir} & ${author_crx_workdir}/repository/"
  chown -R aem-author:aem-author /opt/aem/author
  chown -R aem-author:aem-author /opt/aem/author/crx-quickstart/repository/*
}

update_publish_permission () {
  echo "Update permissions to aem-publish:aem-publish for path ${publish_workdir} & ${publish_crx_workdir}/repository/"
  chown -R aem-publish:aem-publish /opt/aem/publish
  chown -R aem-publish:aem-publish /opt/aem/publish/crx-quickstart/repository/*
}

upgrade_author () {
  cd ${author_workdir}
  java -server -Xmx4096m -Dcom.adobe.upgrade.forcemigration=true \
  -Djava.awt.headless=true -Dsling.run.modes=author,crx3,crx3tar \
  -jar crx-quickstart/app/cq-quickstart-6.4.0-standalone-quickstart.jar start -c crx-quickstart -i launchpad \
  -p 4502 -Dsling.properties=crx-quickstart/conf/sling.properties  > /dev/null 2>&1 &
  echo $!
}

upgrade_publish () {
  cd ${publish_workdir}
  java -server -Xmx4096m -Dcom.adobe.upgrade.forcemigration=true \
  -Djava.awt.headless=true -Dsling.run.modes=publish,crx3,crx3tar \
  -jar crx-quickstart/app/cq-quickstart-6.4.0-standalone-quickstart.jar start -c crx-quickstart -i launchpad \
  -p 4503 -Dsling.properties=crx-quickstart/conf/sling.properties  > /dev/null 2>&1 &
  echo $!
}


echo "Upgrading AEM to AEM 6.4"
echo "."
echo "Upgrade Steps:"
echo "1. Stopping Author instance"
echo "2. Stopping Publish instance"
echo "3. Start Author instance from jar file"
echo "4. Start Publish instance from jar file"
echo "5. Configure Audit purge log and workflow purge manually"
echo "6. Create Version Purge rule."
echo "7. Create workflow Purge rule."
echo "8. Create Audit Purge rule."
echo "9. Please run Version, Audit and workflow purge job manually"
echo "10. Please uninstall any existing acs-aem-common-content package manually"
echo "11. Run RevisionGarbageCollection"
echo "12. Disable Author replication agents manually"
echo "13. Install pre upgrade tasks for Author instance"
echo "14. Install pre upgrade tasks for Publish instance"
echo "15. Trigger run of all pre upgrade tasks for author instance"
echo "16. Trigger run of all pre upgrade tasks for publish instance"
echo "17. Check if pre upgrade tasks where successfully manually"
echo "18. Stop of Author & Publish process"
echo "19. Copy Files needed for Upgrading"
echo "20. Create Backup"
echo "21. Remove old .bak files from repository"
echo "22. Run offline compaction job"
echo "23. Unpack AEM 64 jar file for Author"
echo "24. Run Repository migration for Author"
echo "25. Check logfiles for success of the repository upgrade"
echo "26. Run AEM Upgrade for Author"
echo "27. Check if AEM Upgrade for Author was successful manually"
echo "28. Stop Author instance"
echo "29. Unpack AEM 64 jar file for Publish"
echo "30. Run Repository migration for Publish"
echo "31. Check logfiles for success of the repository upgrade"
echo "32. Run AEM Upgrade for Publish"
echo "33. Check if AEM Upgrade for Publish was successful manually"
echo "34. Stop Publish instance"
echo "35. Run Post-Upgrade jobs"
echo "35.1 Start AEM Author"
echo "35.2 Start AEM Publish"
echo "35.3 Check if AEM successfully starts manually"
echo "35.4 Stop org.apache.sling.rewriter bundle"
echo "35.5 Install ACS Bundles netty"
echo "35.6 Install ACS AEM Tools"
echo "35.7 Install ACS AEM Comons Content"
echo "35.8 Stop AEM Author"
echo "35.9 Stop AEM Publish"
echo "36. Run offline Snapshot "
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
stop_aem_publish
echo "."
echo "."
java_run=true
wait_publish_stopped
echo "."
echo "."
echo "Starting Publish instance without any options"
publish_pid=$(start_publish_plain)
java_run=false
wait_publish_started
echo "."
echo "."
echo "Please configure Audit purge log and workflow purge manually"
echo "http://localhost:4502/system/console/configMgr"
echo "http://localhost:4503/system/console/configMgr"
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
  echo "."
  echo "."
  echo "Create Version Purge rule for Publish."
  curl -f -u admin:admin \
   -F 'jcr:primaryType=nt:unstructured' \
   -F 'sling:resourceType=granite/operations/components/maintenance/task' \
   -F ':redirect=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_daily' \
   -F 'name=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_daily' \
   -F 'granite.task.disclaimer=' \
   -F 'granite.task.hint=' \
   -F 'granite.maintenance.name=com.day.cq.wcm.core.impl.VersionPurgeTask' \
   'http://localhost:4503/apps/granite/operations/config/maintenance/_granite_daily/*'
  translate_exit_code "$?"
  echo "Version Purge rule for Publish created."
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
  echo "."
  echo "."
  echo "Create workflow Purge rule for Publish."
  curl -f -u admin:admin \
   -F 'jcr:primaryType=nt:unstructured' \
   -F 'sling:resourceType=granite/operations/components/maintenance/task' \
   -F ':redirect=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'name=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'granite.task.disclaimer=' \
   -F 'granite.maintenance.name=WorkflowPurgeTask' \
   'http://localhost:4503/apps/granite/operations/config/maintenance/_granite_weekly/*'
  translate_exit_code "$?"
  echo "workflow Purge rule for Publish created."
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
  echo "."
  echo "."
  echo "Create Audit Purge rule for Publish."
  curl -f -u admin:admin \
   -F 'jcr:primaryType=nt:unstructured' \
   -F 'sling:resourceType=granite/operations/components/maintenance/task' \
   -F ':redirect=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'name=/libs/granite/operations/content/maintenanceWindow.html/mnt/overlay/granite/operations/config/maintenance/_granite_weekly' \
   -F 'granite.task.hint=' \
   -F 'granite.maintenance.name=com.day.cq.audit.impl.AuditLogMaintenanceTask' \
   'http://localhost:4503/apps/granite/operations/config/maintenance/_granite_weekly/*'
  translate_exit_code "$?"
  echo "Audit Purge rule for Publish created."
fi
echo "."
echo "."
echo "Please run Version, Audit and workflow purge job manually and wait till it's finished succesfully."
echo "http://localhost:4502/libs/granite/operations/content/maintenance.html"
echo "http://localhost:4503/libs/granite/operations/content/maintenance.html"
read -p "Press enter to continue"
echo "."
echo "."
echo "Please uninstall any existing acs-aem-common-content package manually"
echo "http://localhost:4502/crx/packmgr/index.jsp"
echo "http://localhost:4503/crx/packmgr/index.jsp"
read -p "Press enter to continue"
echo "."
echo "."
echo "Run RevisionGarbageCollection"
curl -f -u admin:admin \
  -X POST \
  "http://localhost:4502/system/console/jmx/org.apache.jackrabbit.oak:name=Segment+node+store+revision+garbage+collection,type=RevisionGarbageCollection/op/startRevisionGC/"
translate_exit_code "$?"
curl -f -u admin:admin \
  -X POST \
  "http://localhost:4503/system/console/jmx/org.apache.jackrabbit.oak:name=Segment+node+store+revision+garbage+collection,type=RevisionGarbageCollection/op/startRevisionGC/"
translate_exit_code "$?"
echo "."
echo "."
echo "Please check if RevisionGarbageCollection was succesfully manually"
echo "http://localhost:4502/system/console/jmx"
echo "http://localhost:4503/system/console/jmx"
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
echo "Install pre upgrade tasks for Publish instance from ${pre_upgrade_package_source}"
${aemtools_workdir}/deploy-artifact.sh publish "${pre_upgrade_package_source}" ${pre_upgrade_package_group} ${pre_upgrade_package_name} ${pre_upgrade_package_version} ${pre_upgrade_package_replicate} ${pre_upgrade_package_activate} ${pre_upgrade_package_force}
translate_exit_code "$?"
echo "."
echo "."
echo "Trigger run of all pre upgrade tasks for author instance"
curl -f -v -u admin:admin -X POST 'http://localhost:4502/system/console/jmx/com.adobe.aem.upgrade.prechecks:type=PreUpgradeTasks/op/runAllPreUpgradeTasks/'
translate_exit_code "$?"
echo "."
echo "."
echo "Trigger run of all pre upgrade tasks for publish instance"
curl -f -v -u admin:admin -X POST 'http://localhost:4503/system/console/jmx/com.adobe.aem.upgrade.prechecks:type=PreUpgradeTasks/op/runAllPreUpgradeTasks/'
translate_exit_code "$?"
echo "."
echo "."
echo "Please check if pre upgrade tasks where successfully manually"
echo 'http://localhost:4502/system/console/jmx/com.adobe.aem.upgrade.prechecks:type=PreUpgradeTasks'
echo 'http://localhost:4503/system/console/jmx/com.adobe.aem.upgrade.prechecks:type=PreUpgradeTasks'
read -p "Press enter to continue"
echo "."
echo "."
echo "Please confirm to stop of Author & Publish process"
read -p "Press enter to continue"
kill ${author_pid} ${publish_pid}
echo "."
java_run=true
wait_author_stopped
echo "."
echo "."
java_run=true
wait_publish_stopped
echo "."
echo "."
echo "."
echo "Copying AEM 6.4 Quickstart file to $author_workdir"
aws s3 cp ${s3_bucket_path}/AEM_6.4_Quickstart.jar $author_workdir/; \
echo "."
echo "."
echo "."
echo "Copying AEM 6.4 Quickstart file to $publish_workdir"
aws s3 cp ${s3_bucket_path}/AEM_6.4_Quickstart.jar $publish_workdir/; \
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
echo "."
echo "creating backup directory ${publish_workdir}/backup"
if [ -d ${publish_workdir}/backup ]; then
  mv ${publish_workdir}/backup ${publish_workdir}/backup_${current_datetime}
  mkdir ${publish_workdir}/backup
else
  mkdir ${publish_workdir}/backup
fi
echo "."
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
echo "."
if [ -f ${publish_workdir}/AEM_6.2_Quickstart.jar ]; then
  echo "Move file ${publish_workdir}/AEM_6.2_Quickstart.jar to ${publish_workdir}/backup"
  mv ${publish_workdir}/AEM_6.2_Quickstart.jar ${publish_workdir}/backup/
fi
echo "."
echo "."
echo "."
if [ -f ${publish_workdir}/aem-publish-4503.jar ]; then
  echo "Move file ${publish_workdir}/aem-publish-4503.jar to ${publish_workdir}/backup"
  mv ${publish_workdir}/aem-publish-4503.jar ${publish_workdir}/backup/
fi
echo "."
echo "."
echo "."
if [ -f ${author_workdir}/AEM_6.4_Quickstart.jar ]; then
  echo "Rename file ${author_workdir}/AEM_6.4_Quickstart.jar to ${author_workdir}/aem-author-4502.jar"
  mv ${author_workdir}/AEM_6.4_Quickstart.jar ${author_workdir}/aem-author-4502.jar
fi
echo "."
echo "."
echo "."
if [ -f ${publish_workdir}/AEM_6.4_Quickstart.jar ]; then
  echo "Rename file ${publish_workdir}/AEM_6.4_Quickstart.jar to ${publish_workdir}/aem-publish-4503.jar"
  mv ${publish_workdir}/AEM_6.4_Quickstart.jar ${publish_workdir}/aem-publish-4503.jar
fi
echo "."
echo "."
echo "Adds execution right to file aem-author-4502.jar"
chmod +x ${author_workdir}/aem-author-4502.jar
echo "."
echo "."
echo "Adds execution right to file aem-publish-4503.jar"
chmod +x ${publish_workdir}/aem-publish-4503.jar
echo "."
echo "."
echo "Create a backup of ${author_crx_workdir} in ${author_workdir}/backup/"
cp -r ${author_crx_workdir} ${author_workdir}/backup/
echo "."
echo "."
echo "Create a backup of ${publish_crx_workdir} in ${publish_workdir}/backup/"
cp -r ${publish_crx_workdir} ${publish_workdir}/backup/
echo "."
echo "."
if [ $enable_delete_bak_files == 'True' ] || [ $enable_delete_bak_files == 'true' ] ; then
  echo "removing .bak files older than ${bak_file_age} days in Author repository ${author_crx_workdir}/repository/"
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
if [ $enable_delete_bak_files == 'True' ] || [ $enable_delete_bak_files == 'true' ] ; then
  echo "removing .bak files older than ${bak_file_age} days in Publisher repository ${publish_crx_workdir}/repository/"
  echo "."
  echo "."
  find ${publish_crx_workdir}/repository/ \
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
update_publish_permission
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
echo "Upgrade for AEM Author is done going ahead with upgrading AEM Publish instance"
read -p "Press enter to continue"
echo "."
echo "."
echo "Unpack aem-publish-4503.jar"
cd ${publish_workdir}
java -Xmx4096m -jar aem-publish-4503.jar -unpack
echo "Unpack aem-publish-4503.jar done"
echo "."
echo "."
echo "Wait till unpacking of aem-publish-4503.jar is done."
echo "Please confirm to go to the next step 'repository upgrade'"
read -p "Press enter to continue"
echo "."
echo "."
update_publish_permission
echo "."
echo "."
echo "Remove old crx2oak jar file from ${publish_crx_workdir}/opt/extensions/"
rm -fv ${publish_crx_workdir}/opt/extensions/crx2oak*.jar
echo "."
echo "."
echo "Copy ${crx2oak_source} to ${publish_crx_workdir}/opt/extensions/crx2oak.jar"
aws s3 cp ${crx2oak_source} ${publish_crx_workdir}/opt/extensions/crx2oak.jar
echo "."
echo "."
echo "Run Repository migration for Publish"
cd ${publish_workdir}
java -Xmx4096m -jar aem-publish-4503.jar -v -x crx2oak -xargs -- --load-profile segment-no-ds
echo "."
echo "."
echo "Wait till repo migration for Publish is done."
update_publish_permission
echo "."
echo "."
echo "Output Last 50 lines of ${publish_crx_workdir}/logs/upgrade.log:"
tail -n 50 ${publish_crx_workdir}/logs/upgrade.log
echo "."
echo "."
echo "Please check logfile ${publish_crx_workdir}/logs/upgrade.log for errors in a different window"
echo "before confirming next step."
echo "Please confirm to go to the next step 'AEM Upgrade'"
read -p "Press enter to continue"
echo "."
echo "."
if [ -f ${publish_crx_workdir}/app/cq-quickstart-6.2.0-standalone-quickstart.jar ]; then
    echo "Copying AEM 6.2 Quickstart file from ${publish_crx_workdir}/app/ to /tmp as it's not needed anymore."
    mv ${publish_crx_workdir}/app/cq-quickstart-6.2.0-standalone-quickstart.jar /tmp
fi
echo "."
echo "."
echo "Run AEM Upgrade for Publish"
publish_pid=$(upgrade_publish)
echo "."
echo "."
echo "Sleep 10 minutes, as update may take around 10 minutes."
sleep 600
echo "Press enter to print last 50 lines of ${publish_crx_workdir}/logs/upgrade.log"
read -p "Press enter to continue"
tail -n 50 ${publish_crx_workdir}/logs/upgrade.logg
echo "."
echo "."
echo "Please check logfile ${publish_crx_workdir}/logs/upgrade.log if upgrade is finished."
read -p "If upgrade is finished press enter to continue"
echo "Stop publish instance"
kill ${publish_pid}
echo "."
echo "."
java_run=true
wait_publish_stopped
update_publish_permission
echo "AEM Upgrade is done!"
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
  start_aem_publish
  echo "."
  echo "."
  java_run=false
  wait_publish_started
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
    echo "Stopping bundle org.apache.sling.rewriter on Publish."
    curl -f -u admin:admin \
     -F action=start \
     http://localhost:4503/system/console/bundles/org.apache.sling.rewriter
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
    echo "Installing ACS AEM commons on Publish"
    ${aemtools_workdir}/deploy-artifact.sh publish "${acs_aem_commons_source}" ${acs_aem_commons_group} ${acs_aem_commons_name} ${acs_aem_commons_version} ${acs_aem_commons_replicate} ${acs_aem_commons_activate} ${acs_aem_commons_force}
    translate_exit_code "$?"
    echo "."
    echo "."
  fi
  read -p "press enter to stop Author & Publish instance."
  echo "."
  echo "."
  stop_aem_author
  echo "."
  echo "."
  java_run=true
  wait_author_stopped
  echo "."
  echo "."
  stop_aem_publish
  echo "."
  echo "."
  java_run=true
  wait_publish_stopped
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
