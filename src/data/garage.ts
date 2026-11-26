export type CarClass = "sedan" | "suv" | "truck";
export interface VehicleOption { make: string; models: { name: string; carClass: CarClass; oilQuarts: number }[] }
export interface RepairService { id: string; category: string; title: string; duration: string; baseLabor: number; basePartsOem: number; basePartsAftermarket: number; warranty: string; note: string }
export interface ServiceRecord { id: string; date: string; vinOrPlate: string; vehicle: string; mileage: string; workDone: string; partsTier: "OEM" | "Aftermarket"; totalCost: number; mechanic: string; status: "Completed" | "Scheduled" }
export const VEHICLES: VehicleOption[] = [
 { make: "Toyota", models: [{name:"Camry (2.5L)",carClass:"sedan",oilQuarts:4.8},{name:"RAV4 (2.5L AWD)",carClass:"suv",oilQuarts:4.8},{name:"Tacoma (3.5L V6)",carClass:"truck",oilQuarts:6.2}] },
 { make: "Honda", models: [{name:"Civic (2.0L / 1.5T)",carClass:"sedan",oilQuarts:3.7},{name:"CR-V (1.5T AWD)",carClass:"suv",oilQuarts:3.7},{name:"Pilot (3.5L V6)",carClass:"suv",oilQuarts:5.7}] },
 { make: "Ford", models: [{name:"Fusion (2.0L EcoBoost)",carClass:"sedan",oilQuarts:5.7},{name:"Explorer (2.3L / 3.0L)",carClass:"suv",oilQuarts:6.0},{name:"F-150 (3.5L / 5.0L V8)",carClass:"truck",oilQuarts:7.7}] },
 { make: "Volkswagen", models: [{name:"Jetta (1.4T / 1.5T)",carClass:"sedan",oilQuarts:4.5},{name:"Tiguan (2.0T 4Motion)",carClass:"suv",oilQuarts:6.0}] },
 { make: "Subaru", models: [{name:"Outback (2.5L / 2.4T)",carClass:"suv",oilQuarts:5.1},{name:"Forester (2.5L)",carClass:"suv",oilQuarts:5.1}] }
];
export const CLASS_MULTIPLIER: Record<CarClass, number> = { sedan: 1, suv: 1.18, truck: 1.35 };
export const SERVICES: RepairService[] = [
 {id:"oil-service",category:"Maintenance",title:"Full synthetic oil & filter service",duration:"45 min",baseLabor:45,basePartsOem:68,basePartsAftermarket:48,warranty:"12 months / 12,000 miles",note:"Premium synthetic oil matched to your engine specification, plus a complimentary fluid and leak check."},
 {id:"brakes-front",category:"Brakes",title:"Front brake pads, rotors & caliper service",duration:"1.5 hours",baseLabor:135,basePartsOem:240,basePartsAftermarket:165,warranty:"24 months / 24,000 miles",note:"Includes hardware cleaning, high-temperature lubricant and rotor runout inspection."},
 {id:"suspension-diag",category:"Suspension",title:"Suspension inspection & 3D wheel alignment",duration:"1 hour",baseLabor:110,basePartsOem:0,basePartsAftermarket:0,warranty:"6 months on alignment",note:"Before-and-after alignment report with photos of any identified wear or play."},
 {id:"engine-diag",category:"Diagnostics",title:"Check Engine diagnostic & intake smoke test",duration:"1 hour",baseLabor:95,basePartsOem:0,basePartsAftermarket:0,warranty:"Clear repair recommendation",note:"A real diagnostic process — not just clearing codes. Includes fuel trim and intake leak checks."},
 {id:"cooling-flush",category:"Cooling",title:"Coolant exchange & cooling system inspection",duration:"1.5 hours",baseLabor:120,basePartsOem:75,basePartsAftermarket:52,warranty:"24 months",note:"Vacuum-filled coolant service, thermostat operation and pressure-cap inspection."},
 {id:"ac-recharge",category:"Climate",title:"A/C service & UV leak inspection",duration:"1 hour",baseLabor:90,basePartsOem:65,basePartsAftermarket:45,warranty:"12 months",note:"Refrigerant recovery, vacuum test and recharge using the correct refrigerant type."}
];
export const INITIAL_HISTORY: ServiceRecord[] = [
 {id:"RR-4812",date:"Oct 14, 2026",vinOrPlate:"TX-8492-KLM",vehicle:"2021 Toyota RAV4 (2.5L AWD)",mileage:"64,210 mi",workDone:"Oil service, front brake pads & rotors",partsTier:"OEM",totalCost:432,mechanic:"Marcus Vega · Bay 2",status:"Completed"},
 {id:"RR-4790",date:"Sep 02, 2026",vinOrPlate:"TX-8492-KLM",vehicle:"2021 Toyota RAV4 (2.5L AWD)",mileage:"61,800 mi",workDone:"Suspension inspection & 3D alignment",partsTier:"OEM",totalCost:130,mechanic:"Daniel Crawford · Bay 4",status:"Completed"},
 {id:"RR-4655",date:"Jul 19, 2026",vinOrPlate:"1FTFW1E50MFB41902",vehicle:"2022 Ford F-150",mileage:"48,950 mi",workDone:"Oil service & coolant exchange",partsTier:"Aftermarket",totalCost:297,mechanic:"Marcus Vega · Bay 1",status:"Completed"}
];
