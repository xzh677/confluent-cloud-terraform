```shell
export BROKER=lkc-ymyzq7-pyv5rp.australia-southeast1.gcp.glb.confluent.cloud:9092
export TOPIC=xyz.topic
export SCOPE=confluent_cloud
export CLIENT_ID=
export CLIENT_SECRET=
export CLUSTER_ID=lkc-ymyzq7
export IDENTITY_POOL_ID=pool-qzRG

tee o-conn.conf << END
security.protocol=SASL_SSL
sasl.oauthbearer.token.endpoint.url=https://dev-61282638.okta.com/oauth2/aus7ufmd9kxOcdgy85d7/v1/token
sasl.login.callback.handler.class=org.apache.kafka.common.security.oauthbearer.secured.OAuthBearerLoginCallbackHandler
sasl.mechanism=OAUTHBEARER
sasl.jaas.config= \
  org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
    clientId='$CLIENT_ID' \
    scope='$SCOPE' \
    clientSecret='$CLIENT_SECRET' \
    extension_logicalCluster='$CLUSTER_ID' \
    extension_identityPoolId='$IDENTITY_POOL_ID';
END
```

```
seq 1 100 | kafka-console-producer --topic $TOPIC \
  --bootstrap-server $BROKER \
  --producer.config o-conn.conf

kafka-console-consumer --topic $TOPIC \
  --from-beginning \
  --bootstrap-server $BROKER \
  --consumer.config o-conn.conf
```