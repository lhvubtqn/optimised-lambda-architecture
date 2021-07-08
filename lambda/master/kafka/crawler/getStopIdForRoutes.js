const fetch = require("node-fetch");
const fs = require("fs");

const OUTPUT_FILE =
  "/home/ubuntu/Desktop/spark-thesis/optimised-lambda-architecture/lambda/storage/data/static_data/routes_with_stops.txt";

main().catch((err) => console.log(err));

async function getArray(endpoint) {
  const res = await fetch(endpoint);
  const json = await res.json();
  return json.items;
}

async function main() {
  const routes_with_stops = [];
  const routes = await getArray(ROUTES_ENPOINT);
  for (route of routes) {
    const endpoint = `http://api.metro.net/agencies/lametro/routes/${route.id}/stops/`;
    const stops = await getArray(endpoint);

    for (stop of stops) {
      const route_with_stops = {
        route_id: route.id,
        stop_id: stop.id,
        stop_lat: stop.latitude,
        stop_lon: stop.longitude,
      };
      routes_with_stops.push(route_with_stops);
    }
  }

  try {
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(routes_with_stops));
  } catch (err) {
    console.error(err);
  }
}
