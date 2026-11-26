$pageTsx = @'
"use client";

import React, { useEffect, useMemo, useState } from "react";
import {
  Wrench,
  ShieldCheck,
  Clock3,
  ArrowRight,
  CheckCircle2,
  ChevronDown,
  Phone,
  MapPin,
  Menu,
  X,
  Search,
  CalendarDays,
  CarFront,
  Star,
  BadgeCheck,
  CircleDollarSign,
  UserPlus,
  LogIn,
  LogOut,
  ClipboardList,
} from "lucide-react";
import {
  VEHICLES,
  CLASS_MULTIPLIER,
  SERVICES,
  INITIAL_HISTORY,
  type ServiceRecord,
} from "@/data/garage";

interface ClientAccount {
  id: string;
  name: string;
  email: string;
  phone: string;
  defaultVehicle: string;
  vinOrPlate: string;
}

interface ServiceRequest {
  id: string;
  createdAt: string;
  ownerEmail: string;
  clientName: string;
  phone: string;
  vehicle: string;
  vinOrPlate: string;
  servicesList: string;
  partsTier: "OEM" | "Aftermarket";
  estimatedCost: number;
  preferredDate: string;
  preferredTime: string;
  message: string;
  status: "New" | "Confirmed" | "In Progress";
}

const money = (n: number) =>
  new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  }).format(n);

const ACCOUNTS_KEY = "rrm_accounts_v1";
const SESSION_KEY = "rrm_session_email_v1";
const REQUESTS_KEY = "rrm_requests_v1";
const HISTORY_KEY = "rrm_history_v1";

export default function Home() {
  const [make, setMake] = useState("Toyota");
  const [model, setModel] = useState("RAV4 (2.5L AWD)");
  const [tier, setTier] = useState<"OEM" | "Aftermarket">("OEM");
  const [selected, setSelected] = useState<string[]>(["oil-service"]);
  const [historyQuery, setHistoryQuery] = useState("");
  const [mobileOpen, setMobileOpen] = useState(false);

  const [accounts, setAccounts] = useState<ClientAccount[]>([]);
  const [currentUser, setCurrentUser] = useState<ClientAccount | null>(null);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [authMode, setAuthMode] = useState<"register" | "login">("register");
  const [authForm, setAuthForm] = useState({
    name: "",
    email: "",
    phone: "",
    vinOrPlate: "",
  });
  const [authError, setAuthError] = useState("");

  const [records, setRecords] = useState<ServiceRecord[]>(INITIAL_HISTORY);
  const [requests, setRequests] = useState<ServiceRequest[]>([]);
  const [form, setForm] = useState({
    name: "",
    email: "",
    phone: "",
    vinOrPlate: "",
    date: "",
    time: "",
    vehicle: "Toyota RAV4 (2.5L AWD)",
    message: "",
  });
  const [notice, setNotice] = useState("");

  useEffect(() => {
    try {
      const savedAccounts = JSON.parse(localStorage.getItem(ACCOUNTS_KEY) || "[]");
      const savedSessionEmail = localStorage.getItem(SESSION_KEY) || "";
      const savedRequests = JSON.parse(localStorage.getItem(REQUESTS_KEY) || "[]");
      const savedHistory = JSON.parse(localStorage.getItem(HISTORY_KEY) || "null");

      if (Array.isArray(savedAccounts)) {
        setAccounts(savedAccounts);
        const active = savedAccounts.find(
          (a: ClientAccount) => a.email.toLowerCase() === savedSessionEmail.toLowerCase()
        );
        if (active) {
          setCurrentUser(active);
          setForm((prev) => ({
            ...prev,
            name: prev.name || active.name,
            email: prev.email || active.email,
            phone: prev.phone || active.phone,
            vinOrPlate: prev.vinOrPlate || active.vinOrPlate,
            vehicle: active.defaultVehicle || prev.vehicle,
          }));
        }
      }
      if (Array.isArray(savedRequests)) {
        setRequests(savedRequests);
      }
      if (Array.isArray(savedHistory) && savedHistory.length > 0) {
        setRecords(savedHistory);
      }
    } catch {
      // Ignore storage errors
    }
  }, []);

  useEffect(() => {
    try {
      localStorage.setItem(ACCOUNTS_KEY, JSON.stringify(accounts));
    } catch {}
  }, [accounts]);

  useEffect(() => {
    try {
      localStorage.setItem(REQUESTS_KEY, JSON.stringify(requests));
    } catch {}
  }, [requests]);

  useEffect(() => {
    try {
      localStorage.setItem(HISTORY_KEY, JSON.stringify(records));
    } catch {}
  }, [records]);

  const vehicleMake = VEHICLES.find((v) => v.make === make) ?? VEHICLES[0];
  const vehicle =
    vehicleMake.models.find((m) => m.name === model) ?? vehicleMake.models[0];
  const selectedServices = SERVICES.filter((s) => selected.includes(s.id));

  const estimate = useMemo(
    () =>
      selectedServices.reduce(
        (sum, s) =>
          sum +
          (s.baseLabor +
            (tier === "OEM" ? s.basePartsOem : s.basePartsAftermarket)) *
            CLASS_MULTIPLIER[vehicle.carClass],
        0
      ),
    [selectedServices, tier, vehicle.carClass]
  );

  const toggleService = (id: string) =>
    setSelected((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );

  const onMakeChange = (newMake: string) => {
    setMake(newMake);
    const nextGroup = VEHICLES.find((v) => v.make === newMake) ?? VEHICLES[0];
    const nextModel = nextGroup.models[0].name;
    setModel(nextModel);
    setForm((prev) => ({ ...prev, vehicle: `${newMake} ${nextModel}` }));
  };

  const onModelChange = (newModel: string) => {
    setModel(newModel);
    setForm((prev) => ({ ...prev, vehicle: `${make} ${newModel}` }));
  };

  const openAuth = (mode: "register" | "login") => {
    setAuthMode(mode);
    setAuthError("");
    setAuthModalOpen(true);
    setMobileOpen(false);
  };

  const handleAuthSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError("");
    const emailClean = authForm.email.trim().toLowerCase();
    if (!emailClean) {
      setAuthError("Введите email для входа или регистрации.");
      return;
    }

    if (authMode === "register") {
      if (!authForm.name.trim() || !authForm.phone.trim()) {
        setAuthError("Укажите имя и телефон для создания аккаунта.");
        return;
      }
      const newAccount: ClientAccount = {
        id: `USR-${Math.floor(1000 + Math.random() * 9000)}`,
        name: authForm.name.trim(),
        email: emailClean,
        phone: authForm.phone.trim(),
        defaultVehicle: `${make} ${model}`,
        vinOrPlate: (authForm.vinOrPlate.trim() || "TX-NEW-01").toUpperCase(),
      };
      setAccounts((prev) => [newAccount, ...prev.filter((a) => a.email !== emailClean)]);
      setCurrentUser(newAccount);
      localStorage.setItem(SESSION_KEY, emailClean);
      setForm((prev) => ({
        ...prev,
        name: newAccount.name,
        email: newAccount.email,
        phone: newAccount.phone,
        vinOrPlate: newAccount.vinOrPlate,
        vehicle: newAccount.defaultVehicle,
      }));
      setAuthModalOpen(false);
      setNotice(`Аккаунт создан для ${newAccount.name} (${newAccount.email}).`);
    } else {
      const existing = accounts.find((a) => a.email.toLowerCase() === emailClean);
      if (!existing) {
        setAuthError("Аккаунт с таким email не найден. Переключитесь на «Регистрация».");
        return;
      }
      setCurrentUser(existing);
      localStorage.setItem(SESSION_KEY, existing.email);
      setForm((prev) => ({
        ...prev,
        name: existing.name,
        email: existing.email,
        phone: existing.phone,
        vinOrPlate: existing.vinOrPlate,
        vehicle: existing.defaultVehicle,
      }));
      setAuthModalOpen(false);
      setNotice(`Вы вошли как ${existing.name}.`);
    }
  };

  const handleLogout = () => {
    setCurrentUser(null);
    localStorage.removeItem(SESSION_KEY);
    setNotice("Вы вышли из аккаунта.");
  };

  const submitBooking = (e: React.FormEvent) => {
    e.preventDefault();
    const id = `RR-${Math.floor(4900 + Math.random() * 900)}`;
    const chosenVehicle = form.vehicle.trim() || `${make} ${model}`;
    const chosenPlate = (
      form.vinOrPlate.trim() ||
      currentUser?.vinOrPlate ||
      "TX-4900-RR"
    ).toUpperCase();
    const chosenServicesText =
      selectedServices.map((s) => s.title).join(", ") || "Inspection & diagnostic check";
    const ownerEmail = (
      form.email.trim() ||
      currentUser?.email ||
      "guest@redriver.local"
    ).toLowerCase();

    const newReq: ServiceRequest = {
      id,
      createdAt: new Date().toLocaleDateString("en-US", {
        month: "short",
        day: "2-digit",
        year: "numeric",
      }),
      ownerEmail,
      clientName: form.name.trim(),
      phone: form.phone.trim(),
      vehicle: chosenVehicle,
      vinOrPlate: chosenPlate,
      servicesList: chosenServicesText,
      partsTier: tier,
      estimatedCost: estimate,
      preferredDate: form.date || "ASAP",
      preferredTime: form.time || "Morning",
      message: form.message.trim(),
      status: "New",
    };

    setRequests((prev) => [newReq, ...prev]);

    setRecords((prev) => [
      {
        id,
        date: form.date || "Upcoming",
        vinOrPlate: chosenPlate,
        vehicle: chosenVehicle,
        mileage: "At check-in",
        workDone: chosenServicesText,
        partsTier: tier,
        totalCost: estimate,
        mechanic: `${form.name} · ${form.phone}`,
        status: "Scheduled",
      },
      ...prev,
    ]);

    setNotice(
      `Заявка №${id} принята (${form.date || "по согласованию"} ${
        form.time || ""
      }) и сохранена в списке заявок.`
    );
    setForm((prev) => ({ ...prev, date: "", time: "", message: "" }));
  };

  const visibleRequests = useMemo(() => {
    if (!currentUser) return requests.slice(0, 6);
    const mine = requests.filter(
      (r) => r.ownerEmail.toLowerCase() === currentUser.email.toLowerCase()
    );
    return mine.length > 0 ? mine : requests.slice(0, 6);
  }, [requests, currentUser]);

  const filtered = records.filter((r) =>
    `${r.id} ${r.date} ${r.vinOrPlate} ${r.vehicle} ${r.workDone} ${r.mechanic} ${r.status}`
      .toLowerCase()
      .includes(historyQuery.toLowerCase())
  );

  return (
    <main id="home" className="page-root">
      <div className="topbar">
        <div className="container topbar-inner">
          <div>
            <span>
              <MapPin size={13} /> Austin, TX · Honest Auto Care
            </span>
            <span>
              <Clock3 size={13} /> Mon–Fri 8am–6pm · Sat 8am–4pm
            </span>
          </div>
          <div className="topbar-right">
            <a href="tel:+15125550184">
              <Phone size={13} /> (512) 555-0184
            </a>
            <a href="#requests">Заявки ({requests.length})</a>
          </div>
        </div>
      </div>

      <header className="site-header">
        <div className="container nav">
          <a className="brand" href="#home" onClick={() => setMobileOpen(false)}>
            <span className="brand-badge">
              <Wrench size={20} />
            </span>
            <span>
              RED RIVER <small>MOTORWORKS</small>
            </span>
          </a>

          <nav className="navlinks">
            <a href="#services">Services</a>
            <a href="#estimate">Estimate</a>
            <a href="#history">History</a>
            <a href="#requests">Requests</a>
            <a href="#booking">Book</a>

            {currentUser ? (
              <div className="account-chip">
                <span className="account-name">{currentUser.name}</span>
                <button
                  type="button"
                  className="ghost-btn"
                  onClick={handleLogout}
                >
                  <LogOut size={14} /> Выйти
                </button>
              </div>
            ) : (
              <button
                type="button"
                className="ghost-btn"
                onClick={() => openAuth("register")}
              >
                <UserPlus size={15} /> Регистрация / Вход
              </button>
            )}

            <a className="btn nav-cta" href="#booking">
              Get an Estimate <ArrowRight size={15} />
            </a>
          </nav>

          <button
            type="button"
            className="mobile-menu"
            aria-label="Toggle menu"
            aria-expanded={mobileOpen}
            onClick={() => setMobileOpen((v) => !v)}
          >
            {mobileOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {mobileOpen && (
          <div className="container mobile-nav">
            <a href="#services" onClick={() => setMobileOpen(false)}>
              Services
            </a>
            <a href="#estimate" onClick={() => setMobileOpen(false)}>
              Cost Calculator
            </a>
            <a href="#history" onClick={() => setMobileOpen(false)}>
              Service History
            </a>
            <a href="#requests" onClick={() => setMobileOpen(false)}>
              My Requests ({requests.length})
            </a>
            <a href="#booking" onClick={() => setMobileOpen(false)}>
              Book Appointment
            </a>
            {currentUser ? (
              <button
                type="button"
                className="btn btn-dark-outline"
                onClick={handleLogout}
              >
                <LogOut size={15} /> Выйти ({currentUser.name})
              </button>
            ) : (
              <button
                type="button"
                className="btn btn-dark-outline"
                onClick={() => openAuth("register")}
              >
                <UserPlus size={15} /> Регистрация / Вход
              </button>
            )}
            <a
              className="btn"
              href="#booking"
              onClick={() => setMobileOpen(false)}
            >
              Get an Estimate <ArrowRight size={15} />
            </a>
          </div>
        )}
      </header>

      <section className="hero">
        <div className="hero-shade" />
        <div className="container hero-grid">
          <div className="hero-copy">
            <span className="eyebrow">AUSTIN AUTO REPAIR &amp; MAINTENANCE</span>
            <h1>
              Honest auto care.
              <br />
              <em>Built on trust.</em>
            </h1>
            <p className="hero-lead">
              From routine maintenance to complex diagnostics, get clear pricing,
              quality parts and technicians who treat your vehicle like their own.
            </p>
            <div className="hero-actions">
              <a className="btn" href="#estimate">
                Calculate Repair Cost <ArrowRight size={16} />
              </a>
              <button
                type="button"
                className="btn hero-secondary-btn"
                onClick={() => openAuth("register")}
              >
                <UserPlus size={16} />
                {currentUser ? `Кабинет: ${currentUser.name}` : "Регистрация"}
              </button>
            </div>
            <div className="hero-proof">
              <div>
                <Star size={15} fill="currentColor" />
                <span>4.9/5 Austin Drivers</span>
              </div>
              <div>
                <ShieldCheck size={16} />
                <span>Upfront Estimates</span>
              </div>
              <div>
                <Wrench size={15} />
                <span>Quality Parts</span>
              </div>
            </div>
          </div>

          <div className="hero-visual">
            <div className="hero-image" />
            <div className="hero-stamp">
              <span>TRUSTED</span>
              <b>AUSTIN</b>
              <small>AUTO CARE</small>
            </div>
          </div>
        </div>

        <div className="container hero-bottom">
          <a className="hero-scroll" href="#services">
            SCROLL TO EXPLORE <ChevronDown size={14} />
          </a>
          <div className="hero-hours">
            <div>
              <small>MON–FRI</small>
              <b>8 AM – 6 PM</b>
            </div>
            <div>
              <small>SATURDAY</small>
              <b>8 AM – 4 PM</b>
            </div>
          </div>
        </div>
      </section>

      <section className="trustbar">
        <div className="container trust-grid">
          <div>
            <BadgeCheck size={19} />
            <span>
              <b>Transparent pricing</b> before work begins
            </span>
          </div>
          <div>
            <Wrench size={19} />
            <span>
              <b>OEM &amp; quality aftermarket</b> parts options
            </span>
          </div>
          <div>
            <ShieldCheck size={19} />
            <span>
              <b>No surprise repairs</b> without your approval
            </span>
          </div>
          <div>
            <CircleDollarSign size={19} />
            <span>
              <b>Straightforward service</b> for daily drivers
            </span>
          </div>
        </div>
      </section>

      <section className="section" id="services">
        <div className="container">
          <div className="section-head">
            <div>
              <span className="eyebrow">WHAT WE DO</span>
              <h2 className="section-title">
                Reliable care for
                <br />
                <em>every mile.</em>
              </h2>
            </div>
            <p className="section-intro">
              Practical maintenance, careful diagnostics and honest repair advice
              designed to keep your vehicle safe and dependable.
            </p>
          </div>
          <div className="service-grid">
            {SERVICES.map((s) => {
              const active = selected.includes(s.id);
              return (
                <article
                  key={s.id}
                  className={`service-card ${active ? "selected" : ""}`}
                >
                  <div className="service-top">
                    <span>{s.category}</span>
                    <small>{s.duration}</small>
                  </div>
                  <h3>{s.title}</h3>
                  <p>{s.note}</p>
                  <div className="service-foot">
                    <span>
                      Labor from <b>{money(s.baseLabor)}</b>
                    </span>
                    <button
                      type="button"
                      className={`mini-btn ${active ? "active" : ""}`}
                      onClick={() => toggleService(s.id)}
                    >
                      {active ? "Selected ✓" : "Add to Estimate"}
                    </button>
                  </div>
                </article>
              );
            })}
          </div>
          <div className="section-action">
            <a className="text-link" href="#estimate">
              Open interactive cost estimator <ArrowRight size={16} />
            </a>
          </div>
        </div>
      </section>

      <section className="estimate-section" id="estimate">
        <div className="container estimate-layout">
          <div className="estimate-copy">
            <span className="eyebrow">UPFRONT ESTIMATE</span>
            <h2 className="section-title">
              Know the estimate
              <br />
              <em>before you book.</em>
            </h2>
            <p>
              Select your vehicle, choose OEM or quality aftermarket parts, and
              check the services you need for a clear estimate.
            </p>
            <div className="estimate-points">
              <div>
                <CheckCircle2 size={17} />
                <span>Clear labor and parts breakdown</span>
              </div>
              <div>
                <CheckCircle2 size={17} />
                <span>OEM or value aftermarket options</span>
              </div>
              <div>
                <CheckCircle2 size={17} />
                <span>Instant transfer into your booking request</span>
              </div>
            </div>
          </div>

          <div className="estimate-card">
            <div className="estimate-head">
              <div>
                <span className="step-tag">VEHICLE &amp; ESTIMATE</span>
                <h3>Build your service estimate</h3>
              </div>
              <CarFront size={22} />
            </div>

            <div className="field-grid">
              <label className="form-field">
                MAKE
                <select
                  value={make}
                  onChange={(e) => onMakeChange(e.target.value)}
                >
                  {VEHICLES.map((v) => (
                    <option key={v.make}>{v.make}</option>
                  ))}
                </select>
              </label>
              <label className="form-field">
                MODEL &amp; ENGINE
                <select
                  value={model}
                  onChange={(e) => onModelChange(e.target.value)}
                >
                  {vehicleMake.models.map((m) => (
                    <option key={m.name}>{m.name}</option>
                  ))}
                </select>
              </label>
            </div>

            <div className="vehicle-specs">
              <div>
                <small>OIL CAPACITY</small>
                <b>{vehicle.oilQuarts} qts</b>
              </div>
              <div>
                <small>CLASS RATE</small>
                <b>{CLASS_MULTIPLIER[vehicle.carClass]}x</b>
              </div>
              <div>
                <small>SELECTED</small>
                <b>
                  {selectedServices.length}{" "}
                  {selectedServices.length === 1 ? "service" : "services"}
                </b>
              </div>
            </div>

            <div className="tier-box">
              <small>PARTS QUALITY</small>
              <div className="tier-toggle">
                <button
                  type="button"
                  className={tier === "OEM" ? "active" : ""}
                  onClick={() => setTier("OEM")}
                >
                  OEM Spec
                </button>
                <button
                  type="button"
                  className={tier === "Aftermarket" ? "active" : ""}
                  onClick={() => setTier("Aftermarket")}
                >
                  Aftermarket
                </button>
              </div>
            </div>

            <div className="checklist">
              {SERVICES.map((s) => {
                const checked = selected.includes(s.id);
                const price =
                  (s.baseLabor +
                    (tier === "OEM" ? s.basePartsOem : s.basePartsAftermarket)) *
                  CLASS_MULTIPLIER[vehicle.carClass];
                return (
                  <label
                    key={s.id}
                    className={`check-row ${checked ? "checked" : ""}`}
                  >
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() => toggleService(s.id)}
                    />
                    <span>
                      <b>{s.title}</b>
                      <small>
                        {s.duration} · {s.warranty}
                      </small>
                    </span>
                    <strong>{money(price)}</strong>
                  </label>
                );
              })}
            </div>

            <div className="estimate-total-row">
              <div>
                <small>ESTIMATED TOTAL</small>
                <span>
                  {make} {model} · {tier}
                </span>
              </div>
              <strong>{money(estimate)}</strong>
            </div>

            <a className="btn btn-full" href="#booking">
              Continue to Booking <ArrowRight size={16} />
            </a>
          </div>
        </div>
      </section>

      <section className="section history-section" id="history">
        <div className="container">
          <div className="history-header">
            <div>
              <span className="eyebrow">YOUR CAR&apos;S STORY</span>
              <h2 className="section-title">
                Service history,
                <br />
                <em>all in one place.</em>
              </h2>
            </div>
            <div className="history-search">
              <Search size={17} />
              <input
                placeholder="Search by vehicle, plate or job ID"
                value={historyQuery}
                onChange={(e) => setHistoryQuery(e.target.value)}
              />
            </div>
          </div>

          <div className="history-table-wrap">
            <table className="history-table">
              <thead>
                <tr>
                  <th>JOB ID / DATE</th>
                  <th>VEHICLE</th>
                  <th>WORK COMPLETED</th>
                  <th>PARTS</th>
                  <th>TOTAL</th>
                  <th>STATUS</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((r) => (
                  <tr key={r.id}>
                    <td>
                      <b>{r.id}</b>
                      <small>{r.date}</small>
                    </td>
                    <td>
                      {r.vehicle}
                      <small>{r.vinOrPlate}</small>
                    </td>
                    <td>
                      {r.workDone}
                      <small>{r.mechanic}</small>
                    </td>
                    <td>{r.partsTier}</td>
                    <td className="cost-cell">{money(r.totalCost)}</td>
                    <td>
                      <span
                        className={`status-badge ${
                          r.status === "Completed" ? "done" : "planned"
                        }`}
                      >
                        <i />
                        {r.status}
                      </span>
                    </td>
                  </tr>
                ))}
                {filtered.length === 0 && (
                  <tr>
                    <td colSpan={6} className="empty-row">
                      No matching service records found.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      <section className="section requests-section" id="requests">
        <div className="container">
          <div className="requests-top">
            <div>
              <span className="eyebrow">CLIENT REQUESTS &amp; ACCOUNT</span>
              <h2 className="section-title">
                Service requests &amp;
                <br />
                <em>client cabinet.</em>
              </h2>
              <p className="muted">
                {currentUser
                  ? `Аккаунт: ${currentUser.name} (${currentUser.email}) · Авто: ${currentUser.defaultVehicle}`
                  : "Зарегистрируйтесь или войдите, чтобы привязать заявки к аккаунту и автозаполнять данные при записи."}
              </p>
            </div>
            <div className="requests-actions">
              {currentUser ? (
                <button
                  type="button"
                  className="ghost-btn"
                  onClick={handleLogout}
                >
                  <LogOut size={15} /> Выйти
                </button>
              ) : (
                <>
                  <button
                    type="button"
                    className="btn"
                    onClick={() => openAuth("register")}
                  >
                    <UserPlus size={15} /> Регистрация
                  </button>
                  <button
                    type="button"
                    className="ghost-btn"
                    onClick={() => openAuth("login")}
                  >
                    <LogIn size={15} /> Войти
                  </button>
                </>
              )}
            </div>
          </div>

          {visibleRequests.length === 0 ? (
            <div className="empty-requests-box">
              <ClipboardList size={20} />
              <span>
                Заявок пока нет. Оформите заявку в блоке «Book» ниже — она сразу
                появится здесь.
              </span>
            </div>
          ) : (
            <div className="requests-grid">
              {visibleRequests.map((req) => (
                <div key={req.id} className="request-card">
                  <div className="request-card-head">
                    <strong>#{req.id}</strong>
                    <span className="req-badge">{req.status}</span>
                  </div>
                  <h4>{req.vehicle}</h4>
                  <p className="req-meta">
                    {req.clientName} · {req.phone} · {req.vinOrPlate}
                  </p>
                  <p className="req-services">{req.servicesList}</p>
                  <div className="request-card-foot">
                    <span>
                      {req.preferredDate} · {req.preferredTime}
                    </span>
                    <b>{money(req.estimatedCost)}</b>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>

      <section className="booking-section" id="booking">
        <div className="container booking-grid">
          <div className="booking-copy">
            <span className="eyebrow">LET&apos;S GET YOU BACK OUT THERE</span>
            <h2 className="section-title">
              Ready when
              <br />
              <em>you are.</em>
            </h2>
            <p>
              Tell us what your vehicle needs. We&apos;ll follow up to confirm
              availability and walk you through the next steps.
            </p>
            <div className="contact-line">
              <Phone />
              <span>
                <small>CALL OUR SHOP</small>
                <b>(512) 555-0184</b>
              </span>
            </div>
            <div className="contact-line">
              <MapPin />
              <span>
                <small>FIND US</small>
                <b>Austin, Texas</b>
              </span>
            </div>
          </div>

          <form className="booking-form" onSubmit={submitBooking}>
            <div className="form-heading">
              <div>
                <span className="step-tag">BOOK AN APPOINTMENT</span>
                <h3>Request a service visit</h3>
              </div>
              <CalendarDays />
            </div>

            {notice && (
              <div className="form-notice">
                <CheckCircle2 size={17} />
                <span>{notice}</span>
              </div>
            )}

            <div className="field-grid">
              <label className="form-field">
                YOUR NAME
                <input
                  required
                  placeholder="Full name"
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                />
              </label>
              <label className="form-field">
                PHONE NUMBER
                <input
                  required
                  type="tel"
                  placeholder="(512) 555-0123"
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                />
              </label>
              <label className="form-field">
                EMAIL (ACCOUNT)
                <input
                  type="email"
                  placeholder="you@example.com"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                />
              </label>
              <label className="form-field">
                PLATE OR VIN
                <input
                  placeholder="TX-8492-KLM"
                  value={form.vinOrPlate}
                  onChange={(e) =>
                    setForm({ ...form, vinOrPlate: e.target.value })
                  }
                />
              </label>
              <label className="form-field">
                PREFERRED DATE
                <input
                  required
                  type="date"
                  min={new Date().toISOString().split("T")[0]}
                  value={form.date}
                  onChange={(e) => setForm({ ...form, date: e.target.value })}
                />
              </label>
              <label className="form-field">
                PREFERRED TIME
                <select
                  value={form.time}
                  onChange={(e) => setForm({ ...form, time: e.target.value })}
                >
                  <option value="">Select a time</option>
                  <option>8:00–10:00 AM</option>
                  <option>10:00 AM–12:00 PM</option>
                  <option>12:00–2:00 PM</option>
                  <option>2:00–4:00 PM</option>
                  <option>4:00–6:00 PM</option>
                </select>
              </label>
            </div>

            <label className="form-field full-field">
              VEHICLE
              <input
                placeholder={`${make} ${model}`}
                value={form.vehicle}
                onChange={(e) => setForm({ ...form, vehicle: e.target.value })}
              />
            </label>

            <label className="form-field full-field">
              HOW CAN WE HELP?
              <textarea
                rows={3}
                placeholder="Tell us a little about what's going on..."
                value={form.message}
                onChange={(e) => setForm({ ...form, message: e.target.value })}
              />
            </label>

            <button className="btn btn-full" type="submit">
              Request appointment ({money(estimate)}) <ArrowRight size={16} />
            </button>
            <small className="form-legal">
              Данные аккаунта и заявок сохраняются в localStorage браузера —
              готово для статического деплоя на GitHub и Cloudflare Pages.
            </small>
          </form>
        </div>
      </section>

      <footer className="footer">
        <div className="container footer-main">
          <div className="footer-brand">
            <a className="brand brand-light" href="#home">
              <span className="brand-badge">
                <Wrench size={20} />
              </span>
              <span>
                RED RIVER <small>MOTORWORKS</small>
              </span>
            </a>
            <p>
              Honest auto care. Skilled hands.
              <br />
              Proud to keep Austin moving.
            </p>
          </div>
          <div>
            <h4>EXPLORE</h4>
            <a href="#services">Our services</a>
            <a href="#estimate">Get an estimate</a>
            <a href="#history">Service history</a>
            <a href="#requests">My requests</a>
            <a href="#booking">Book appointment</a>
          </div>
          <div>
            <h4>GET IN TOUCH</h4>
            <a href="tel:+15125550184">(512) 555-0184</a>
            <a href="mailto:hello@redrivermotorworks.example">
              Email the shop
            </a>
            <span>Austin, TX</span>
          </div>
          <div className="footer-hours">
            <h4>SHOP HOURS</h4>
            <span>
              Monday – Friday <b>8 AM – 6 PM</b>
            </span>
            <span>
              Saturday <b>8 AM – 4 PM</b>
            </span>
            <span>
              Sunday <b>Closed</b>
            </span>
          </div>
        </div>
        <div className="container footer-bottom">
          <span>© 2026 RED RIVER MOTORWORKS. ALL RIGHTS RESERVED.</span>
          <span>DESIGNED FOR DRIVERS. BUILT ON TRUST.</span>
        </div>
      </footer>

      {authModalOpen && (
        <div className="modal-backdrop" onClick={() => setAuthModalOpen(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-head">
              <h3>
                {authMode === "register"
                  ? "Регистрация клиента"
                  : "Вход в аккаунт"}
              </h3>
              <button
                type="button"
                className="icon-close"
                aria-label="Close modal"
                onClick={() => setAuthModalOpen(false)}
              >
                <X size={18} />
              </button>
            </div>

            <div className="modal-tabs">
              <button
                type="button"
                className={authMode === "register" ? "active" : ""}
                onClick={() => {
                  setAuthMode("register");
                  setAuthError("");
                }}
              >
                Регистрация
              </button>
              <button
                type="button"
                className={authMode === "login" ? "active" : ""}
                onClick={() => {
                  setAuthMode("login");
                  setAuthError("");
                }}
              >
                Вход
              </button>
            </div>

            {authError && <div className="auth-error">{authError}</div>}

            <form onSubmit={handleAuthSubmit}>
              {authMode === "register" && (
                <>
                  <label className="form-field">
                    ИМЯ И ФАМИЛИЯ
                    <input
                      required
                      placeholder="Иван Петров"
                      value={authForm.name}
                      onChange={(e) =>
                        setAuthForm({ ...authForm, name: e.target.value })
                      }
                    />
                  </label>
                  <label className="form-field">
                    ТЕЛЕФОН
                    <input
                      required
                      type="tel"
                      placeholder="(512) 555-0199"
                      value={authForm.phone}
                      onChange={(e) =>
                        setAuthForm({ ...authForm, phone: e.target.value })
                      }
                    />
                  </label>
                </>
              )}

              <label className="form-field">
                EMAIL
                <input
                  required
                  type="email"
                  placeholder="driver@example.com"
                  value={authForm.email}
                  onChange={(e) =>
                    setAuthForm({ ...authForm, email: e.target.value })
                  }
                />
              </label>

              {authMode === "register" && (
                <label className="form-field">
                  ГОСНОМЕР ИЛИ VIN АВТО
                  <input
                    placeholder="TX-8492-KLM"
                    value={authForm.vinOrPlate}
                    onChange={(e) =>
                      setAuthForm({ ...authForm, vinOrPlate: e.target.value })
                    }
                  />
                </label>
              )}

              <button type="submit" className="btn btn-full">
                {authMode === "register"
                  ? "Создать аккаунт"
                  : "Войти в кабинет"}
              </button>
            </form>
          </div>
        </div>
      )}
    </main>
  );
}
'@

$extraCss = @'

.page-root{overflow-x:clip}
.topbar-right{display:flex;align-items:center;gap:18px}
.account-chip{display:inline-flex;align-items:center;gap:8px;background:#f4f2ed;border:1px solid #dedbd4;border-radius:5px;padding:5px 10px;font-size:12px}
.account-name{font-weight:700;color:#141719;max-width:130px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.ghost-btn{display:inline-flex;align-items:center;gap:6px;background:#fff;border:1px solid #d4cfc5;color:#181c20;border-radius:5px;padding:8px 12px;font-size:12px;font-weight:700;cursor:pointer;text-decoration:none}
.ghost-btn:hover{border-color:#141719}
.nav-cta{padding:10px 14px;font-size:12px}
.hero-secondary-btn{background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.32);color:#fff}
.hero-secondary-btn:hover{background:rgba(255,255,255,.2)}
.btn-dark-outline{background:#fff;color:#141719;border-color:#141719}
.requests-section{background:#f9f8f5;border-top:1px solid #e6e3dc}
.requests-top{display:flex;justify-content:space-between;align-items:flex-end;gap:24px;margin-bottom:28px;flex-wrap:wrap}
.requests-actions{display:flex;gap:10px;flex-wrap:wrap}
.empty-requests-box{display:flex;align-items:center;gap:12px;background:#fff;border:1px dashed #ccc7bd;border-radius:6px;padding:18px 20px;color:#525960;font-size:14px}
.requests-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}
.request-card{background:#fff;border:1px solid #dedbd4;border-radius:6px;padding:18px;display:flex;flex-direction:column;gap:8px}
.request-card-head{display:flex;justify-content:space-between;align-items:center}
.req-badge{font-size:11px;font-weight:700;background:#fff2ef;color:#a93625;padding:3px 9px;border-radius:999px}
.request-card h4{margin:0;font-size:16px;font-weight:800;color:#141719}
.req-meta{margin:0;font-size:12px;color:#687078}
.req-services{margin:0;font-size:13px;color:#2b3137;line-height:1.45;flex:1}
.request-card-foot{display:flex;justify-content:space-between;align-items:center;padding-top:10px;border-top:1px solid #ece9e2;font-size:12px;color:#525960}
.request-card-foot b{font-size:15px;color:#141719}
.modal-backdrop{position:fixed;inset:0;background:rgba(10,13,16,.65);z-index:100;display:grid;place-items:center;padding:16px}
.modal-card{width:min(440px,100%);background:#fff;border-radius:8px;padding:24px;border:1px solid #dedbd4;box-shadow:0 24px 60px rgba(0,0,0,.35)}
.modal-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
.modal-head h3{margin:0;font-size:19px;font-weight:800;color:#141719}
.icon-close{background:none;border:1px solid #dedbd4;border-radius:5px;width:32px;height:32px;display:grid;place-items:center;cursor:pointer;color:#141719}
.modal-tabs{display:grid;grid-template-columns:1fr 1fr;gap:8px;background:#f4f2ed;padding:4px;border-radius:6px;margin-bottom:16px}
.modal-tabs button{border:none;background:transparent;padding:8px;border-radius:4px;font-size:13px;font-weight:700;color:#525960;cursor:pointer}
.modal-tabs button.active{background:#141719;color:#fff}
.auth-error{background:#fdecea;border:1px solid #f5c2c7;color:#842029;padding:10px 12px;border-radius:5px;font-size:13px;margin-bottom:14px}

@media (max-width: 900px){
  .requests-grid{grid-template-columns:1fr 1fr}
}

@media (max-width: 700px){
  .topbar-inner{flex-direction:column;align-items:flex-start;gap:4px;padding:8px 0}
  .topbar-right{gap:12px;flex-wrap:wrap}
  .requests-grid{grid-template-columns:1fr}
  .mobile-nav{display:grid;gap:12px;padding:16px 0 20px;border-top:1px solid #ece9e2}
  .mobile-nav a{text-decoration:none;font-weight:700;font-size:14px;padding:4px 0}
  .service-foot{flex-direction:column;align-items:flex-start;gap:10px}
  .mini-btn{width:100%}
  .history-table{min-width:620px}
}
'@

Set-Content -Path ".\src\app\page.tsx" -Value $pageTsx -Encoding UTF8
Add-Content -Path ".\src\app\globals.css" -Value $extraCss -Encoding UTF8
Write-Host "Updated src/app/page.tsx and src/app/globals.css successfully."
