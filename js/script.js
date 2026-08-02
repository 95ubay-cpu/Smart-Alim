// ===========================================================
// SMART TA'LIM — shared logic (updated to load dictionaries from JSON)
// ===========================================================

/* ---------- Lugʻat yuklash: data/dictionaries.json faylidan ---------- */
let DICTIONARY = []; // qayta to'ldiriladi fetch orqali

// Fallback qisqa ro'yxat (agar fetch ishlamasa sahifa ishlayveradi)
const FALLBACK_DICTIONARY = [
  { en: "book",       uz: "kitob",        pos: "n." },
  { en: "university", uz: "universitet",  pos: "n." },
  { en: "student",    uz: "talaba",       pos: "n." },
  { en: "teacher",    uz: "oʻqituvchi",   pos: "n." },
  { en: "knowledge",  uz: "bilim",        pos: "n." },
  { en: "exam",       uz: "imtihon",      pos: "n." },
  { en: "smart",      uz: "aqlli",        pos: "adj." },
  { en: "science",    uz: "fan",          pos: "n." },
];

function loadDictionary(){
  return fetch('/data/dictionaries.json')
    .then(res=>{
      if(!res.ok) throw new Error('Network response not ok');
      return res.json();
    })
    .then(data=>{
      if(Array.isArray(data) && data.length) {
        DICTIONARY = data;
      } else DICTIONARY = FALLBACK_DICTIONARY;
    })
    .catch(err=>{
      console.warn('Dictionary load failed, using fallback:', err);
      DICTIONARY = FALLBACK_DICTIONARY;
    });
}

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

  input.addEventListener('input', ()=> render(input.value));

  function render(query){
    const q = (query||'').trim().toLowerCase();
    let list = DICTIONARY;
    if(q){
      list = DICTIONARY.filter(item=>{
        const key = direction === 'en-uz' ? item.en : item.uz;
        return key && key.toLowerCase().includes(q);
      });
    }
    if(!list || list.length === 0){
      resultsBox.innerHTML = `<div class="empty"><div class="ic">🔍</div><p>Hech narsa topilmadi. Boshqa soʻz bilan izlab koʻring.</p></div>`;
      return;
    }
    resultsBox.innerHTML = list.map(item=>{
      const word = direction === 'en-uz' ? item.en : item.uz;
      const def  = direction === 'en-uz' ? item.uz : item.en;
      const pos = item.pos ? `<span class="pos">${item.pos}</span>` : '';
      return `<div class="dict-result">
        <span class="word">${word}</span>${pos}
        <div class="def">${def}</div>
      </div>`;
    }).join('');
  }

  // dastlab render uchun bo'shcha chaqiriq
  render('');
}

// DOM yuklangach dictionary ni yuklab init qilish
document.addEventListener('DOMContentLoaded', ()=>{
  loadDictionary().then(()=> initDictionary());
});

/* ---------- Boshqa umumiy funksiyalar (masalan list filter) ---------- */
function initListFilter(inputId, selector){
  const input = document.getElementById(inputId);
  if(!input) return;
  input.addEventListener('input', ()=>{
    const q = input.value.trim().toLowerCase();
    document.querySelectorAll(selector).forEach(el=>{
      const txt = el.innerText.toLowerCase();
      el.style.display = q && !txt.includes(q) ? 'none' : '';
    });
  });
}

// end of file
