import Link from "next/link";
export default function Home() {
  return (
    <main className="min-h-screen flex items-center justify-center p-6">
      <div className="text-center">
        <h1 className="text-3xl font-bold">RoamOS </h1>
        <p className="mt-4">
          <Link href="/api/health" className="underline">/api/health</Link>
        </p>
      </div>
    </main>
  );
}
