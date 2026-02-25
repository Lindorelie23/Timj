import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

type SmsPayload = {
  Body?: string;
  From?: string;
};

type ReportFields = {
  departmentCode: string;
  type: string;
  severity: number;
  location: string;
  needs: string;
  details: string;
};

const parseSmsReport = (raw: string): ReportFields | null => {
  if (!raw.startsWith("AIA#")) {
    return null;
  }

  const pairs = raw.split("#").slice(1);
  const map = new Map<string, string>();

  for (const pair of pairs) {
    const [key, ...valueChunks] = pair.split("=");
    if (!key || valueChunks.length === 0) {
      continue;
    }
    map.set(key.trim().toUpperCase(), valueChunks.join("=").trim());
  }

  const departmentCode = map.get("DEPT") ?? "INCONNU";
  const type = map.get("TYPE") ?? "Non précisé";
  const severityRaw = map.get("SEV") ?? "1";
  const location = map.get("LOC") ?? "Non précisé";
  const needs = map.get("BESOIN") ?? "Aucun";
  const details = map.get("DETAIL") ?? "";

  const severity = Number.parseInt(severityRaw, 10);
  const clampedSeverity = Number.isNaN(severity) ? 1 : Math.max(1, Math.min(5, severity));

  return {
    departmentCode,
    type,
    severity: clampedSeverity,
    location,
    needs,
    details,
  };
};

export const receiveSmsReport = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const body = req.body as SmsPayload;
  const smsText = body.Body ?? "";
  const sender = body.From ?? "unknown";

  const parsed = parseSmsReport(smsText);
  if (!parsed) {
    res.status(400).send("Format invalide. Utilisez: AIA#DEPT=...#TYPE=...#SEV=...#LOC=...");
    return;
  }

  await db.collection("reports").add({
    ...parsed,
    source: "sms",
    sender,
    status: "new",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.info("SMS report ingested", {sender, departmentCode: parsed.departmentCode});
  res.status(200).send("Rapport reçu. Merci.");
});

export const health = onRequest((_req, res) => {
  res.status(200).json({status: "ok", service: "aia-connect-functions"});
});
