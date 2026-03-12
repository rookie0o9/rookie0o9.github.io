"use strict";

var PRODUCTION_HOST = "blog.fixam.co.uk";
var BOT_USER_AGENT =
  /(bot|spider|crawler|preview|headless|slurp|curl|wget|python-requests|facebookexternalhit|discordbot|linkedinbot|whatsapp|pingdom|uptimerobot|checkly)/i;

function header(event, name) {
  if (!event || !event.headers) {
    return "";
  }

  return event.headers[name] || event.headers[name.toLowerCase()] || "";
}

function cleanText(value, fallback, maxLength) {
  var text = typeof value === "string" ? value : fallback;
  if (!text) {
    return fallback;
  }

  return text.replace(/\s+/g, " ").trim().slice(0, maxLength);
}

function normalizePath(value) {
  try {
    var url = new URL(value || "/", "https://" + PRODUCTION_HOST);
    return (url.pathname + url.search).slice(0, 180);
  } catch (error) {
    return "/";
  }
}

exports.handler = async function (event) {
  if (event.httpMethod !== "POST") {
    return {
      statusCode: 405,
      headers: { Allow: "POST" },
      body: "Method Not Allowed"
    };
  }

  if (!process.env.TELEGRAM_BOT_TOKEN || !process.env.TELEGRAM_CHAT_ID) {
    return { statusCode: 204 };
  }

  var requestHost = cleanText(
    header(event, "x-forwarded-host") || header(event, "host"),
    "",
    120
  ).replace(/:\d+$/, "");

  if (requestHost !== PRODUCTION_HOST) {
    return { statusCode: 202 };
  }

  var userAgent = cleanText(header(event, "user-agent"), "unknown", 220);
  if (BOT_USER_AGENT.test(userAgent)) {
    return { statusCode: 202 };
  }

  var payload = {};
  try {
    payload = JSON.parse(event.body || "{}");
  } catch (error) {
    return { statusCode: 400, body: "Invalid JSON" };
  }

  var path = normalizePath(payload.path);
  var title = cleanText(payload.title, "untitled", 140);
  var referrer = cleanText(payload.referrer, "direct", 220);
  var visitedAt = cleanText(payload.visitedAt, new Date().toISOString(), 40);

  var message = [
    "FIXAM // LAB NOTES visit",
    "path: " + path,
    "title: " + title,
    "referrer: " + referrer,
    "time: " + visitedAt,
    "ua: " + userAgent
  ].join("\n");

  var response = await fetch(
    "https://api.telegram.org/bot" + process.env.TELEGRAM_BOT_TOKEN + "/sendMessage",
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        chat_id: process.env.TELEGRAM_CHAT_ID,
        text: message,
        disable_web_page_preview: true
      })
    }
  );

  if (!response.ok) {
    console.error("telegram send failed", await response.text());
    return { statusCode: 502, body: "Notification failed" };
  }

  return { statusCode: 204 };
};
