import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = {
 title: "Red River Motorworks | Austin Auto Repair & Service",
 description: "Honest auto repair in Austin, TX. Get a transparent estimate, choose quality parts and book your service online."
};
export default function RootLayout({children}:{children:React.ReactNode}) {
 return <html lang="en"><body>{children}</body></html>;
}
