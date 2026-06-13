/* ============================================================
   Meducyte landing — interactions (Lunera-style rebuild)
   ============================================================ */
(function () {
  'use strict';
  const $ = (s, c = document) => c.querySelector(s);
  const $$ = (s, c = document) => Array.from(c.querySelectorAll(s));
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const finePointer = window.matchMedia('(pointer:fine)').matches;

  /* ---------- footer year ---------- */
  $('#year').textContent = new Date().getFullYear();

  /* ============================================================
     HEADER — alive
     ============================================================ */
  const header = $('#header');
  const navMenu = $('#navMenu');
  const indicator = $('#navIndicator');
  const navLinks = $$('a[data-spy]', navMenu);
  const statusText = $('.header__statusText');

  // shrink on scroll
  const onScroll = () => header.classList.toggle('is-scrolled', window.scrollY > 40);
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // sliding indicator: follows hover, falls back to active section
  let activeLink = null;
  function moveIndicator(link) {
    if (!link) { indicator.classList.remove('is-on'); return; }
    indicator.style.left = link.offsetLeft + 'px';
    indicator.style.width = link.offsetWidth + 'px';
    indicator.classList.add('is-on');
  }
  navLinks.forEach((a) => {
    a.addEventListener('mouseenter', () => moveIndicator(a));
  });
  navMenu.addEventListener('mouseleave', () => moveIndicator(activeLink));

  // scrollspy: highlight the section currently in view
  const spyTargets = navLinks
    .map((a) => document.getElementById(a.dataset.spy))
    .filter(Boolean);
  if ('IntersectionObserver' in window) {
    const spy = new IntersectionObserver((entries) => {
      entries.forEach((en) => {
        if (en.isIntersecting) {
          const link = navLinks.find((a) => a.dataset.spy === en.target.id);
          if (!link) return;
          navLinks.forEach((l) => l.classList.remove('is-active'));
          link.classList.add('is-active');
          activeLink = link;
          if (!navMenu.matches(':hover')) moveIndicator(link);
          if (statusText) statusText.textContent = en.target.id;
        }
      });
    }, { rootMargin: '-35% 0px -55% 0px' });
    spyTargets.forEach((t) => spy.observe(t));
  }
  // reset status text near top
  window.addEventListener('scroll', () => {
    if (window.scrollY < 200) {
      navLinks.forEach((l) => l.classList.remove('is-active'));
      activeLink = null;
      if (!navMenu.matches(':hover')) moveIndicator(null);
      if (statusText) statusText.textContent = 'online';
    }
  }, { passive: true });

  // magnetic buttons (header CTA + hero/cta)
  if (finePointer && !reduceMotion) {
    $$('.btn--magnet').forEach((btn) => {
      const strength = 0.35;
      btn.addEventListener('mousemove', (e) => {
        const r = btn.getBoundingClientRect();
        const x = (e.clientX - r.left - r.width / 2) * strength;
        const y = (e.clientY - r.top - r.height / 2) * strength;
        btn.style.transform = `translate(${x.toFixed(1)}px, ${y.toFixed(1)}px)`;
      });
      btn.addEventListener('mouseleave', () => { btn.style.transform = ''; });
    });
  }

  // mobile sheet
  const navToggle = $('#navToggle');
  navToggle.addEventListener('click', () => {
    const open = header.classList.toggle('is-open');
    navToggle.setAttribute('aria-expanded', String(open));
  });
  $('#navSheet').addEventListener('click', (e) => {
    if (e.target.tagName === 'A') {
      header.classList.remove('is-open');
      navToggle.setAttribute('aria-expanded', 'false');
    }
  });

  /* ============================================================
     HERO — widget parallax + sparkline
     ============================================================ */
  const widgets = $$('.widget[data-depth]');
  if (widgets.length && finePointer && !reduceMotion) {
    let tx = 0, ty = 0, cx = 0, cy = 0, raf = null;
    const hero = $('.hero');
    hero.addEventListener('mousemove', (e) => {
      const r = hero.getBoundingClientRect();
      tx = (e.clientX - r.left) / r.width - 0.5;
      ty = (e.clientY - r.top) / r.height - 0.5;
      if (!raf) loop();
    });
    function loop() {
      cx += (tx - cx) * 0.06;
      cy += (ty - cy) * 0.06;
      widgets.forEach((w) => {
        const d = parseFloat(w.dataset.depth) || 10;
        w.style.transform = `translate(${(-cx * d).toFixed(1)}px, ${(-cy * d).toFixed(1)}px)`;
      });
      raf = Math.abs(tx - cx) + Math.abs(ty - cy) > 0.001 ? requestAnimationFrame(loop) : null;
    }
  }
  // draw sparkline when visible
  const spark = $('.spark');
  if (spark && 'IntersectionObserver' in window) {
    const sio = new IntersectionObserver((entries) => {
      entries.forEach((en) => { if (en.isIntersecting) { spark.classList.add('is-drawn'); sio.disconnect(); } });
    }, { threshold: 0.4 });
    sio.observe(spark);
  }

  /* ============================================================
     REVEAL + COUNTERS
     ============================================================ */
  const revealEls = $$('.reveal');
  if ('IntersectionObserver' in window && !reduceMotion) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((en) => {
        if (en.isIntersecting) { en.target.classList.add('is-visible'); io.unobserve(en.target); }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
    revealEls.forEach((el, i) => { el.style.transitionDelay = (i % 3) * 70 + 'ms'; io.observe(el); });
  } else {
    revealEls.forEach((el) => el.classList.add('is-visible'));
  }

  const animateCount = (el) => {
    const target = parseFloat(el.dataset.count);
    const dur = 1400, start = performance.now();
    const fmt = (n) => Math.round(n).toLocaleString('en-US');
    const tick = (now) => {
      const t = Math.min((now - start) / dur, 1);
      el.textContent = fmt(target * (1 - Math.pow(1 - t, 3)));
      if (t < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  };
  const countEls = $$('[data-count]');
  if ('IntersectionObserver' in window) {
    const cio = new IntersectionObserver((entries) => {
      entries.forEach((en) => { if (en.isIntersecting) { animateCount(en.target); cio.unobserve(en.target); } });
    }, { threshold: 0.5 });
    countEls.forEach((el) => cio.observe(el));
  } else {
    countEls.forEach((el) => { el.textContent = parseFloat(el.dataset.count).toLocaleString('en-US'); });
  }

  /* ============================================================
     SPECIALTIES MARQUEE
     ============================================================ */
  const specialties = [
    'Cardiology', 'Neurology', 'Pneumology', 'Hepato-Gastroenterology', 'Emergency Medicine',
    'Internal Medicine', 'Nephrology', 'Gynecology & Obstetrics', 'Hematology', 'Anesthesiology',
    'Infectious Disease', 'Rheumatology', 'Geriatrics', 'Pediatrics', 'Toxicology',
    'Psychiatry', 'Orthopedics', 'Oncology', 'Dermatology', 'ENT', 'Ophthalmology',
    'Endocrinology', 'Urology', 'Neurosurgery', 'Critical Care'
  ];
  const track = $('#marqueeTrack');
  if (track) {
    const html = specialties.map((s) => `<span>${s}</span>`).join('');
    track.innerHTML = html + html;
  }

  /* ============================================================
     QUIZ DEMO
     ============================================================ */
  const questions = [
    {
      tag: 'CARDIOLOGY',
      q: 'A 72-year-old with non-valvular atrial fibrillation, hypertension and diabetes. Which score guides anticoagulation here?',
      options: ['Wells score', 'CHA₂DS₂-VASc', 'Glasgow Coma Scale', 'Apgar score'],
      answer: 1,
      explain: '<b>CHA₂DS₂-VASc</b> estimates annual stroke risk in non-valvular AF and guides oral anticoagulation. This patient already scores ≥2, so anticoagulation is recommended.'
    },
    {
      tag: 'PNEUMOLOGY',
      q: 'Which finding best distinguishes a transudative from an exudative pleural effusion (Light’s criteria)?',
      options: ['Pleural pH < 7.2', 'Pleural/serum protein ratio > 0.5', 'Glucose < 60 mg/dL', 'Presence of lymphocytes'],
      answer: 1,
      explain: 'By <b>Light’s criteria</b>, an effusion is exudative if the pleural/serum protein ratio is > 0.5 (or LDH ratio > 0.6, or pleural LDH > 2/3 the upper serum limit).'
    },
    {
      tag: 'NEPHROLOGY',
      q: 'A patient has metabolic acidosis with a normal anion gap. Which cause is most consistent?',
      options: ['Diabetic ketoacidosis', 'Lactic acidosis', 'Diarrhea', 'Methanol poisoning'],
      answer: 2,
      explain: '<b>Diarrhea</b> causes bicarbonate loss → normal anion-gap (hyperchloremic) acidosis. The others raise the anion gap by adding unmeasured acids.'
    },
    {
      tag: 'NEUROLOGY',
      q: 'Best initial imaging for a patient with sudden “worst headache of life” suggesting subarachnoid hemorrhage?',
      options: ['Non-contrast CT head', 'MRI with contrast', 'Carotid ultrasound', 'EEG'],
      answer: 0,
      explain: 'A <b>non-contrast CT</b> is first-line and most sensitive within 6 hours. If negative but suspicion remains, proceed to lumbar puncture for xanthochromia.'
    }
  ];

  const quiz = $('#quiz');
  if (quiz) {
    const elTag = $('#quizTag'), elQ = $('#quizQuestion'), elOpts = $('#quizOptions');
    const elExplain = $('#quizExplain'), elNext = $('#quizNext'), elScore = $('#quizScore');
    const keys = ['A', 'B', 'C', 'D'];
    let idx = 0, answered = false, correctCount = 0, attempts = 0;

    function render() {
      const item = questions[idx];
      answered = false;
      elTag.textContent = item.tag;
      elQ.textContent = item.q;
      elExplain.hidden = true;
      elExplain.innerHTML = '';
      elNext.disabled = true;
      elOpts.innerHTML = '';
      item.options.forEach((opt, i) => {
        const b = document.createElement('button');
        b.className = 'quiz__opt';
        b.type = 'button';
        b.innerHTML = `<span class="key">${keys[i]}</span><span>${opt}</span>`;
        b.addEventListener('click', () => choose(i, b));
        elOpts.appendChild(b);
      });
    }

    function choose(i, btn) {
      if (answered) return;
      answered = true;
      attempts++;
      const item = questions[idx];
      const opts = $$('.quiz__opt', elOpts);
      opts.forEach((o) => (o.disabled = true));
      opts[item.answer].classList.add('is-correct');
      if (i === item.answer) correctCount++;
      else btn.classList.add('is-wrong');
      elScore.textContent = `SCORE ${correctCount}/${attempts}`;
      elExplain.innerHTML = (i === item.answer ? '✅ <b>Correct.</b> ' : '❌ <b>Not quite.</b> ') + item.explain;
      elExplain.hidden = false;
      elNext.disabled = false;
    }

    elNext.addEventListener('click', () => {
      idx = (idx + 1) % questions.length;
      render();
      quiz.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth', block: 'center' });
    });

    render();
  }

  /* ============================================================
     SCIENCE — forgetting curve
     ============================================================ */
  const forgetSvg = $('#forgetSvg');
  if (forgetSvg) {
    const X0 = 40, X1 = 400, Y0 = 240, Y1 = 40;
    const xAt = (d) => X0 + (d / 30) * (X1 - X0);
    const yAt = (p) => Y0 - (p / 100) * (Y0 - Y1);

    let cram = `M ${xAt(0)} ${yAt(100)}`;
    for (let d = 1; d <= 30; d++) cram += ` L ${xAt(d).toFixed(1)} ${yAt(100 * Math.exp(-d / 6)).toFixed(1)}`;
    $('#curveCram').setAttribute('d', cram);

    const reviews = [0, 3, 8, 16, 30];
    let srs = '';
    const dots = $('#srsDots');
    for (let r = 0; r < reviews.length - 1; r++) {
      const startD = reviews[r], endD = reviews[r + 1];
      const top = 100, floor = 70 + r * 6;
      srs += (r === 0 ? `M ${xAt(startD)} ${yAt(top)}` : ` L ${xAt(startD).toFixed(1)} ${yAt(top).toFixed(1)}`);
      const span = endD - startD;
      for (let s = 1; s <= span; s++) {
        const frac = s / span;
        const p = top - (top - floor) * (1 - Math.exp(-frac * 2.2)) / (1 - Math.exp(-2.2));
        srs += ` L ${xAt(startD + s).toFixed(1)} ${yAt(p).toFixed(1)}`;
      }
      const c = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
      c.setAttribute('cx', xAt(startD)); c.setAttribute('cy', yAt(top)); c.setAttribute('r', '4');
      dots.appendChild(c);
    }
    $('#curveSrs').setAttribute('d', srs);

    const draw = () => {
      $('#curveSrs').classList.add('is-drawn');
      $('#curveCram').classList.add('is-drawn');
      $$('#srsDots circle').forEach((c, i) => setTimeout(() => c.classList.add('show'), 700 + i * 200));
    };
    if ('IntersectionObserver' in window && !reduceMotion) {
      const rio = new IntersectionObserver((entries) => {
        entries.forEach((en) => { if (en.isIntersecting) { draw(); rio.disconnect(); } });
      }, { threshold: 0.4 });
      rio.observe(forgetSvg);
    } else { draw(); }

    const segWith = $('#segWith'), segWithout = $('#segWithout');
    const retNum = $('#retNum'), retCmp = $('#retCmp');
    const setMode = (withSrs) => {
      segWith.classList.toggle('is-active', withSrs);
      segWithout.classList.toggle('is-active', !withSrs);
      $('#curveSrs').style.opacity = withSrs ? '1' : '0.2';
      $('#curveCram').style.opacity = withSrs ? '0.3' : '0.9';
      $$('#srsDots circle').forEach((c) => (c.style.opacity = withSrs ? '1' : '0.15'));
      retNum.textContent = withSrs ? '92%' : '21%';
      retCmp.textContent = withSrs ? 'recall after 30 days — vs 21% from cramming' : 'recall after 30 days without review';
    };
    segWith.addEventListener('click', () => setMode(true));
    segWithout.addEventListener('click', () => setMode(false));
  }
})();
