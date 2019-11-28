Recovery Steps
--------------

The following recovery steps are implemented as part of AEM Full-Set environment built-in feature.

#### Orchestrator recovery steps

1. Orchestrator instance gets terminated
2. Orchestrator AutoScalingGroup launches a new instance to replace the one that got terminated
3. New Orchestrator instance resumes processing AutoScalingGroup events on SQS queue which was created by the creation of the AEM Full-Set environment

#### Chaos-Monkey recovery steps

1. Chaos-Monkey instance gets terminated
2. Chaos-Monkey AutoScalingGroup launches a new instance to replace the one that got terminated
3. New Chaos-Monkey instance resumes its functionality using the same SimpleDB database which was created by the original Chaos-Monkey instance provisioning

#### Author-Dispatcher recovery steps

1. Author-Dispatcher instance gets terminated
2. Termination event is consumed by AEM Orchestrator via SNS and SQS
3. AEM Orchestrator removes the flush agent on Author-Primary which used to point to the terminated Author-Dispatcher instance
4. Author-Dispatcher AutoScalingGroup launches a new instance to replace the one that got terminated
5. Launch event is consumed by AEM Orchestrator
6. AEM Orchestrator creates a new flush agent on Author-Primary and points it to the newly launched Author-Dispatcher instance

#### Publish-Dispatcher recovery steps

1. Publish-Dispatcher instance gets terminated
2. Termination event is consumed by AEM Orchestrator via SNS and SQS
3. AEM Orchestrator terminates the Publish instance that used to be paired to the terminated Publish-Dispatcher instance
4. AEM Orchestrator removes the replication agent on Author-Primary which used to point to the terminated Publish instance
5. Publish-Dispatcher AutoScalingGroup launches a new instance to replace the one that got terminated
6. Launch event is consumed by AEM Orchestrator
7. AEM Orchestrator modifies Publish AutoScalingGroup to ensure the creation of a new Publish instance to replace the one that got terminated
8. AEM Orchestrator pairs the newly launched Publish instance with the newly launched Publish-Dispatcher instance by tagging each other's instance ID
9. The newly launched Publish instance creates a flush agent on itself which points to its Publish-Dispatcher instance pair
10. AEM Orchestrator creates a new replication agent on Author-Primary and points it to the newly launched Publish instance

#### Publish recovery steps

1. Publish instance gets terminated
2. Termination event is consumed by AEM Orchestrator via SNS and SQS
3. AEM Orchestrator terminates the Publish-Dispatcher instance that used to be paired to the terminated Publish instance
4. AEM Orchestrator removes the replication agent on Author-Primary which used to point to the terminated Publish instance
5. Publish-Dispatcher AutoScalingGroup launches a new instance to replace the one that got terminated
6. Launch event is consumed by AEM Orchestrator
7. AEM Orchestrator modifies Publish AutoScalingGroup to ensure the creation of a new Publish instance to replace the one that got terminated
8. AEM Orchestrator pairs the newly launched Publish instance with the newly launched Publish-Dispatcher instance by tagging each other's instance ID
9. The newly launched Publish instance creates a flush agent on itself which points to its Publish-Dispatcher instance pair
10. AEM Orchestrator creates a new replication agent on Author-Primary and points it to the newly launched Publish instance

#### Author-Primary recovery steps

1. Author-Primary instance gets terminated
2. Promote Author-Standby instance to become an Author-Primary, which allows content authoring activity to continue, but the environment is at an incomplete state for losing an Author-Standby
3. Take latest offline snapshots, and use them to create a new AEM Full-Set environment
4. Direct all traffic to the new AEM Full-Set environment

Please note that we have a backlog task to automate the recovery of Author-Primary and Author-Standby termination.

#### Author-Standby recovery steps

1. Author-Standby instance gets terminated
2. At this point, content authoring activity can still continue, but the environment is at an incomplete state for losing an Author-Standby
3. Take latest offline snapshots, and use them to create a new AEM Full-Set environment
4. Direct all traffic to the new AEM Full-Set environment

Please note that we have a backlog task to automate the recovery of Author-Primary and Author-Standby termination.
