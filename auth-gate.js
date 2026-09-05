// Smart Ta'lim — sayt bo'ylab avtorizatsiya darvozasi
// VAQTINCHA O'CHIRILGAN: Supabase loyihalari qayta yaratilib, yangi kalit kiritilgach
// quyidagi "if (!DARVOZA) return;" qatorini olib tashlang (yoki DARVOZA = true).
(function(){
  const DARVOZA = false;
  if (!DARVOZA) return;
  try {
    var cur = location.pathname.split('/').pop() || 'index.html';
    var ochiq = ['kirish.html','royxatdan-otish.html','404.html','maxfiylik.html'];
    if (ochiq.indexOf(cur) !== -1) return;

    var ls = window.localStorage, bor = false;
    for (var i = 0; i < ls.length; i++) {
      var k = ls.key(i);
      if (k && k.indexOf('sb-') === 0 && k.indexOf('-auth-token') > -1) { bor = true; break; }
    }
    if (!bor) location.replace('/kirish.html');
  } catch(e) {}
})();