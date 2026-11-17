param(
    [string]$FontDir,
    [string]$OutDir
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force $OutDir | Out-Null

function Get-FontB64([string]$name) {
    return [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $FontDir "$name.woff2")))
}

function Escape-Xml([string]$s) {
    return $s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace('"', "&quot;")
}

function Write-Svg([string]$path, [string]$content) {
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($path, $content, $utf8)
}

$unbounded = Get-FontB64 "unbounded"
$fira = Get-FontB64 "firacode"
$firaBold = Get-FontB64 "firacodebold"

$fontFace = @"
@font-face { font-family: "Unbounded"; font-weight: 800; src: url(data:font/woff2;base64,$unbounded) format("woff2"); }
@font-face { font-family: "Fira Code"; font-weight: 400; src: url(data:font/woff2;base64,$fira) format("woff2"); }
@font-face { font-family: "Fira Code"; font-weight: 600; src: url(data:font/woff2;base64,$firaBold) format("woff2"); }
"@

# ---------- Capa ----------

function New-Wave([double]$y, [double]$amp, [double]$period, [double]$width) {
    $half = $period / 2
    $d = "M 0 $y Q $($half / 2) $($y - $amp) $half $y"
    $x = $half
    while ($x -lt $width) {
        $x += $half
        $d += " T $x $y"
    }
    return $d
}

$W = 1200
$H = 300
$wave1 = New-Wave 232 18 300 ($W * 2)
$wave2 = New-Wave 250 12 220 ($W * 2)
$wave3 = New-Wave 70 10 260 ($W * 2)

$banner = @"
<svg xmlns="http://www.w3.org/2000/svg" width="$W" height="$H" viewBox="0 0 $W $H">
<style>
$fontFace
.nome { font-family: "Unbounded", sans-serif; font-weight: 800; font-size: 78px; fill: #fff; letter-spacing: 3px; opacity: 0; animation: entra 1.2s cubic-bezier(.2,.8,.2,1) .2s forwards; }
.cargo { font-family: "Fira Code", monospace; font-weight: 400; font-size: 22px; fill: #fff; letter-spacing: 9px; opacity: 0; animation: aparece 1s ease .9s forwards; }
.linha { stroke: #fff; stroke-width: 2; opacity: 0; animation: aparece 1s ease 1.1s forwards; }
.cursor { fill: #fff; animation: pisca 1s steps(1) infinite; }
.tag { font-family: "Fira Code", monospace; font-weight: 600; font-size: 20px; fill: #fff; opacity: .55; }
.onda { fill: none; stroke: #fff; }
.o1 { stroke-width: 2.5; opacity: .9; animation: corre 14s linear infinite; }
.o2 { stroke-width: 1.5; opacity: .45; animation: corre 9s linear infinite reverse; }
.o3 { stroke-width: 1.5; opacity: .3; animation: corre 18s linear infinite; }
@keyframes entra { from { opacity: 0; transform: translateY(18px); } to { opacity: 1; transform: translateY(0); } }
@keyframes aparece { to { opacity: 1; } }
@keyframes pisca { 50% { opacity: 0; } }
@keyframes corre { from { transform: translateX(0); } to { transform: translateX(-${W}px); } }
</style>
<rect width="$W" height="$H" fill="#000"/>
<path class="onda o3" d="$wave3"/>
<path class="onda o2" d="$wave2"/>
<path class="onda o1" d="$wave1"/>
<text class="tag" x="40" y="48">&lt;/&gt;</text>
<text class="tag" x="$($W - 40)" y="48" text-anchor="end">{ }</text>
<text class="nome" x="600" y="150" text-anchor="middle">HENRIQUE MAIA</text>
<line class="linha" x1="300" y1="190" x2="370" y2="190"/>
<text class="cargo" x="600" y="198" text-anchor="middle">CHATBOT DEVELOPER</text>
<line class="linha" x1="830" y1="190" x2="900" y2="190"/>
<rect class="cursor" x="912" y="180" width="12" height="22"/>
</svg>
"@
Write-Svg (Join-Path $OutDir "capa.svg") $banner

# ---------- Rodapé ----------

$waveF1 = New-Wave 60 14 300 ($W * 2)
$waveF2 = New-Wave 75 9 220 ($W * 2)
$footer = @"
<svg xmlns="http://www.w3.org/2000/svg" width="$W" height="120" viewBox="0 0 $W 120">
<style>
.onda { fill: none; stroke: #fff; }
.o1 { stroke-width: 2.5; opacity: .9; animation: corre 14s linear infinite; }
.o2 { stroke-width: 1.5; opacity: .45; animation: corre 9s linear infinite reverse; }
@keyframes corre { from { transform: translateX(0); } to { transform: translateX(-${W}px); } }
</style>
<rect width="$W" height="120" fill="#000"/>
<path class="onda o2" d="$waveF2"/>
<path class="onda o1" d="$waveF1"/>
</svg>
"@
Write-Svg (Join-Path $OutDir "rodape.svg") $footer

# ---------- Terminal ----------
# Cada linha: lista de pares (classe, texto). Classes: k = palavra-chave, s = string, c = comentário, f = função, p = normal

$code = @(
    ,@(,@("c", '// cliente: "Cadê meu pedido?"'))
    ,@(@("k", "async function "), @("f", "run"), @("p", "(idPedido) {"))
    ,@(@("p", "    "), @("k", "try"), @("p", " {"))
    ,@(@("p", "        "), @("k", "const"), @("p", " resposta = "), @("k", "await"), @("p", " request."), @("f", "fetchAsync"), @("p", "(API_PEDIDOS + idPedido)"))
    ,@(@("p", "        "), @("k", "const"), @("p", " pedido = JSON."), @("f", "parse"), @("p", "(resposta.body)"))
    ,@(,@("p", ""))
    ,@(@("p", "        "), @("k", "return"), @("p", " "), @("s", '"Seu pedido está "'), @("p", " + pedido.status"))
    ,@(@("p", "    } "), @("k", "catch"), @("p", " (erro) {"))
    ,@(@("p", "        "), @("k", "return"), @("p", " "), @("s", '"SCRIPT_ERROR [consulta-pedido] "'), @("p", " + erro"))
    ,@(,@("p", "    }"))
    ,@(,@("p", "}"))
)

$FS = 15
$CW = $FS * 0.6
$LH = 25
$PADX = 64
$TOP = 70
$TW = 860
$TH = $TOP + $code.Count * $LH + 30

# tempo de digitação: 0.035s por caractere, pausa curta entre linhas, 4s parado no fim
$PER_CHAR = 0.035
$GAP = 0.15
$HOLD = 4.0

$starts = @()
$durs = @()
$t = 0.6
foreach ($line in $code) {
    $len = ($line | ForEach-Object { $_[1].Length } | Measure-Object -Sum).Sum
    $d = [Math]::Max(0.05, $len * $PER_CHAR)
    $starts += $t
    $durs += $d
    $t += $d + $GAP
}
$TOTAL = [Math]::Round($t + $HOLD, 2)

$inv = [Globalization.CultureInfo]::InvariantCulture
function F([double]$v) { return $v.ToString("0.####", $inv) }

$clips = ""
$lines = ""
$nums = ""
for ($i = 0; $i -lt $code.Count; $i++) {
    $line = $code[$i]
    $len = ($line | ForEach-Object { $_[1].Length } | Measure-Object -Sum).Sum
    $w = [Math]::Ceiling($len * $CW) + 2
    $y = $TOP + $i * $LH
    $k1 = F ($starts[$i] / $TOTAL)
    $k2 = F (($starts[$i] + $durs[$i]) / $TOTAL)
    $steps = [Math]::Max(1, $len)

    # largura do recorte cresce em degraus (efeito de digitação) e volta a zero no fim do ciclo
    $vals = New-Object System.Collections.Generic.List[string]
    $keys = New-Object System.Collections.Generic.List[string]
    $vals.Add("0"); $keys.Add("0")
    $vals.Add("0"); $keys.Add($k1)
    for ($s = 1; $s -le $steps; $s++) {
        $vals.Add((F ([Math]::Min($w, $s * $CW + 2))))
        $keys.Add((F (($starts[$i] + $durs[$i] * $s / $steps) / $TOTAL)))
    }
    $vals.Add((F $w)); $keys.Add("1")

    $clips += "<clipPath id=`"l$i`"><rect x=`"$($PADX - 1)`" y=`"$($y - $FS - 2)`" height=`"$($LH)`" width=`"0`"><animate attributeName=`"width`" dur=`"$(F $TOTAL)s`" repeatCount=`"indefinite`" calcMode=`"discrete`" values=`"$($vals -join ';')`" keyTimes=`"$($keys -join ';')`"/></rect></clipPath>`n"

    $spans = ($line | ForEach-Object { "<tspan class=`"$($_[0])`">$(Escape-Xml $_[1])</tspan>" }) -join ""
    $lines += "<text x=`"$PADX`" y=`"$y`" xml:space=`"preserve`" clip-path=`"url(#l$i)`">$spans</text>`n"
    $nums += "<text class=`"n`" x=`"$($PADX - 22)`" y=`"$y`" text-anchor=`"end`">$($i + 1)</text>`n"
}

$terminal = @"
<svg xmlns="http://www.w3.org/2000/svg" width="$TW" height="$TH" viewBox="0 0 $TW $TH">
<style>
$fontFace
text { font-family: "Fira Code", monospace; font-size: ${FS}px; fill: #fff; }
.k { font-weight: 600; fill: #fff; }
.f { font-weight: 600; fill: #fff; text-decoration: underline; }
.s { fill: #b5b5b5; }
.c { fill: #7a7a7a; font-style: italic; }
.p { fill: #e8e8e8; }
.n { fill: #4a4a4a; }
.titulo { font-size: 13px; fill: #8a8a8a; }
</style>
<defs>
$clips</defs>
<rect x="1" y="1" width="$($TW - 2)" height="$($TH - 2)" rx="12" fill="#000" stroke="#fff" stroke-opacity=".35" stroke-width="1.5"/>
<line x1="1" y1="40" x2="$($TW - 1)" y2="40" stroke="#fff" stroke-opacity=".18"/>
<circle cx="24" cy="21" r="6" fill="#fff"/>
<circle cx="44" cy="21" r="6" fill="#fff" fill-opacity=".55"/>
<circle cx="64" cy="21" r="6" fill="#fff" fill-opacity=".25"/>
<text class="titulo" x="$($TW / 2)" y="25" text-anchor="middle">consulta-pedido.js — Blip · Executar script</text>
$nums$lines</svg>
"@
Write-Svg (Join-Path $OutDir "terminal.svg") $terminal

"capa: {0:N0} bytes | rodape: {1:N0} | terminal: {2:N0} | ciclo {3}s" -f (Get-Item (Join-Path $OutDir "capa.svg")).Length, (Get-Item (Join-Path $OutDir "rodape.svg")).Length, (Get-Item (Join-Path $OutDir "terminal.svg")).Length, $TOTAL
