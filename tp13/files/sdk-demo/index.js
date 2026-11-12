// TP13 partie 2 : le même code fonctionne sur Floci et sur AWS ; seul le endpoint change.
import { S3Client, CreateBucketCommand, PutObjectCommand, ListObjectsV2Command } from "@aws-sdk/client-s3";
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

const common = {
  region: process.env.AWS_REGION ?? "us-east-1",
  // AWS_ENDPOINT_URL est lu par le SDK v3 ; on le passe aussi explicitement pour la lisibilité.
  endpoint: process.env.AWS_ENDPOINT_URL ?? "http://localhost:4566",
  credentials: { accessKeyId: "test", secretAccessKey: "test" },
};

const s3 = new S3Client({ ...common, forcePathStyle: true });
const bucket = process.env.BUCKET ?? "tp13-demo";

// Crée le bucket s'il n'existe pas encore (utile dans un Floci neuf lancé par Compose)
await s3.send(new CreateBucketCommand({ Bucket: bucket })).catch(() => {});
await s3.send(new PutObjectCommand({ Bucket: bucket, Key: "hello.txt", Body: "Bonjour Floci" }));
const { Contents = [] } = await s3.send(new ListObjectsV2Command({ Bucket: bucket }));
console.log("Objets du bucket :", Contents.map((o) => o.Key));

// Partie 2 : message JSON dans la file SQS dont l'URL est fournie par QUEUE_URL.
const queueUrl = process.env.QUEUE_URL;
if (queueUrl) {
  const sqs = new SQSClient(common);
  const body = JSON.stringify({ event: "contact.created", at: new Date().toISOString() });
  const { MessageId } = await sqs.send(new SendMessageCommand({ QueueUrl: queueUrl, MessageBody: body }));
  console.log("Message SQS envoyé :", MessageId, body);
} else {
  console.log("QUEUE_URL absente : pas d'envoi SQS");
}
