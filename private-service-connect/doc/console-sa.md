
### Configuration
```shell
export BROKER=lkc-ymyzq7-pyv5rp.australia-southeast1.gcp.glb.confluent.cloud:9092
export TOPIC=abc.topic
export API_KEY=
export API_KEY_SECRET=

tee conn.conf << END
security.protocol=SASL_SSL
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username='$API_KEY' password='$API_KEY_SECRET';
sasl.mechanism=PLAIN
END
```

```
seq 1 100 | kafka-console-producer --topic $TOPIC \
  --bootstrap-server $BROKER \
  --producer.config conn.conf

kafka-console-consumer --topic $TOPIC \
  --from-beginning \
  --bootstrap-server $BROKER \
  --consumer.config conn.conf
```
