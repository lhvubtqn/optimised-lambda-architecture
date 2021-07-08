const fetch = require("node-fetch");
const kafka = require("node-rdkafka");

const END_POINT = "http://api.metro.net/agencies/lametro/vehicles/";

const BOOTSTRAP_SERVERS = process.env.BOOTSTRAP_SERVERS;
const TOPIC = process.env.TOPIC;

const WAIT_TIME_MS_BEFORE_START = process.env.WAIT_TIME_MS_BEFORE_START;
const CRAWL_INTERVAL_MS = process.env.CRAWL_INTERVAL_MS;

const producer = new kafka.Producer({
  "metadata.broker.list": BOOTSTRAP_SERVERS,
});

producer.connect();

function send(key, msg) {
  try {
    producer.produce(TOPIC, null, Buffer.from(msg), key, Date.now());
  } catch (err) {
    console.error(err);
  }
}

async function crawl() {
  const res = await fetch(END_POINT);
  const json = await res.json();
  json.items.forEach((i) => send(i.id, JSON.stringify(i)));
  console.log(`Produce ${json.items.length} messages into Kafka.`);
  producer.poll();
}

producer.on("ready", () => {
  setTimeout(
    () =>
      setInterval(
        () => crawl().catch((err) => console.log(err)),
        CRAWL_INTERVAL_MS
      ),
    WAIT_TIME_MS_BEFORE_START
  );
});

producer.on("event.error", function (err) {
  console.error("Error from producer");
  console.error(err);
});
