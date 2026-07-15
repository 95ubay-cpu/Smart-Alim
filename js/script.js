// ===========================================================
// SMART TA'LIM — shared logic
// ===========================================================

/* ---------- Ingliz-Oʻzbek lugʻat (namuna maʼlumotlar bazasi) ---------- */
const DICTIONARY = [
  { en: "book",       uz: "kitob",        pos: "n." },
  { en: "university", uz: "universitet",  pos: "n." },
  { en: "student",    uz: "talaba",       pos: "n." },
  { en: "teacher",    uz: "oʻqituvchi",   pos: "n." },
  { en: "knowledge",  uz: "bilim",        pos: "n." },
  { en: "exam",       uz: "imtihon",      pos: "n." },
  { en: "scholarship",uz: "grant",        pos: "n." },
  { en: "lecture",    uz: "maʼruza",      pos: "n." },
  { en: "library",    uz: "kutubxona",    pos: "n." },
  { en: "diploma",    uz: "diplom",       pos: "n." },
  { en: "to learn",   uz: "oʻrganmoq",    pos: "v." },
  { en: "to teach",   uz: "oʻqitmoq",     pos: "v." },
  { en: "to study",   uz: "oʻqimoq",      pos: "v." },
  { en: "smart",      uz: "aqlli",        pos: "adj." },
  { en: "science",    uz: "fan",          pos: "n." },
];

/* ---------- Lugʻat sahifasi mantig'i ---------- */
function initDictionary(){
  const input = document.getElementById('dict-search');
  const resultsBox = document.getElementById('dict-results');
  const toggleBtns = document.querySelectorAll('.dict-toggle button');
  if(!input || !resultsBox) return;

  let direction = 'en-uz'; // yoki 'uz-en'

  toggleBtns.forEach(btn=>{
    btn.addEventListener('click', ()=>{
      toggleBtns.forEach(b=>b.classList.remove('active'));
      btn.classList.add('active');
      direction = btn.dataset.dir;
      render(input.value);
    });
  });

  function render(query){
    const q = query.trim().toLowerCase();
    let list = DICTIONARY;
    if(q){
      list = DICTIONARY.filter(item=>{
        const key = direction === 'en-uz' ? item.en : item.uz;
        return key.toLowerCase().includes(q);
      });
    }
    if(list.length === 0){
      resultsBox.innerHTML = `<div class="empty"><div class="ic">🔍</div><p>Hech narsa topilmadi. Boshqa soʻz bilan izlab koʻring.</p></div>`;
      return;
    }
    resultsBox.innerHTML = list.map(item=>{
      const word = direction === 'en-uz' ? item.en : item.uz;
      const def  = direction === 'en-uz' ? item.uz : item.en;
      return `<div class="dict-result">
        <span class="word">${word}</span><span class="pos">${item.pos}</span>
        <div class="def">${def}</div>
      </div>`;
    }).join('');
  }

  input.addEventListener('input', ()=>render(input.value));
  render('');
}

/* ---------- Umumiy qidiruv filtri (kitoblar/universitetlar) ---------- */
function initListFilter(searchId, listSelector){
  const input = document.getElementById(searchId);
  if(!input) return;
  input.addEventListener('input', ()=>{
    const q = input.value.trim().toLowerCase();
    document.querySelectorAll(listSelector).forEach(card=>{
      const text = card.textContent.toLowerCase();
      card.style.display = text.includes(q) ? 'flex' : 'none';
    });
  });
}

/* ---------- Chip filtrlash ---------- */
function initChips(rowId, cb){
  const row = document.getElementById(rowId);
  if(!row) return;
  row.querySelectorAll('.chip').forEach(chip=>{
    chip.addEventListener('click', ()=>{
      row.querySelectorAll('.chip').forEach(c=>c.classList.remove('active'));
      chip.classList.add('active');
      cb && cb(chip.dataset.value);
    });
  });
}

/* ---------- Oddiy demo-chat ---------- */
function initChat(){
  const form   = document.getElementById('chat-form');
  const input  = document.getElementById('chat-input');
  const body   = document.getElementById('chat-body');
  if(!form) return;

  const replies = [
    "Rahmat, savolingizni koʻrib chiqdim!",
    "Bu mavzu boʻyicha kutubxona boʻlimida koʻplab kitoblar bor.",
    "Universitetlar roʻyxatini \"Universitetlar\" boʻlimidan topishingiz mumkin.",
    "Yana savolingiz boʻlsa, bemalol yozavering."
  ];

  form.addEventListener('submit', e=>{
    e.preventDefault();
    const text = input.value.trim();
    if(!text) return;
    body.insertAdjacentHTML('beforeend', `<div class="bubble out">${escapeHtml(text)}</div>`);
    input.value = '';
    body.scrollTop = body.scrollHeight;
    setTimeout(()=>{
      const r = replies[Math.floor(Math.random()*replies.length)];
      body.insertAdjacentHTML('beforeend', `<div class="bubble in">${r}</div>`);
      body.scrollTop = body.scrollHeight;
    }, 500);
  });
}

function escapeHtml(str){
  const d = document.createElement('div');
  d.textContent = str;
  return d.innerHTML;
}

/* ---------- Init on load ---------- */
document.addEventListener('DOMContentLoaded', ()=>{
  initDictionary();
  initChat();
});
