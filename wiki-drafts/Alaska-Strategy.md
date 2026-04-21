<section class="card section">
	<div class="kicker">Alaska strategy</div>
	<h2 class="section-title">Layered Alaska Map Build</h2>
	<p>
		This page describes the recommended map build strategy for Alaska.
		The approach uses layered regions, combining low-zoom statewide coverage
		with higher-detail local areas.
	</p>
</section>

<section class="grid grid-2 section">
	<div class="card">
		<div class="kicker">Region structure</div>
		<h2 class="section-title">Map stack</h2>
		<ul class="simple-list">
			<li><strong>Alaska</strong> - statewide context (low zoom)</li>
			<li><strong>Fairbanks</strong> - primary operating region</li>
			<li><strong>Delta Junction</strong> - Interior corridor coverage</li>
			<li><strong>Tok</strong> - high-detail travel and remote operations area</li>
		</ul>
	</div>

	<div class="card">
		<div class="kicker">Recommended flow</div>
		<h2 class="section-title">Build in layers</h2>
		<p>
			Build maps in layers using multiple commands that all target the same SD card.
			This keeps storage efficient while improving local detail where it matters most.
		</p>
	</div>
</section>

<section class="grid grid-2 section">
	<div class="card">
		<div class="kicker">1. Statewide Alaska</div>
		<h2 class="section-title">Context layer</h2>
<pre>./build-core.sh "Alaska" 4 7 terrain TDECK-AK</pre>
		<ul class="simple-list">
			<li>Full map context</li>
			<li>Zoomed-out navigation</li>
			<li>Minimal storage impact</li>
		</ul>
	</div>

	<div class="card">
		<div class="kicker">2. Fairbanks</div>
		<h2 class="section-title">Primary detail layer</h2>
<pre>./build-core.sh "Fairbanks, Alaska" 6 12 terrain TDECK-AK</pre>
		<ul class="simple-list">
			<li>Detailed terrain</li>
			<li>Primary mesh and field operations area</li>
			<li>Core map usability</li>
		</ul>
	</div>
</section>

<section class="grid grid-2 section">
	<div class="card">
		<div class="kicker">3. Delta Junction</div>
		<h2 class="section-title">Corridor layer</h2>
<pre>./build-core.sh "Delta Junction, Alaska" 7 11 terrain TDECK-AK</pre>
		<ul class="simple-list">
			<li>Interior travel coverage</li>
			<li>Extended operational range</li>
			<li>Road system continuity</li>
		</ul>
	</div>

	<div class="card">
		<div class="kicker">4. Tok</div>
		<h2 class="section-title">High-detail layer</h2>
<pre>./build-core.sh "Tok, Alaska" 8 13 terrain TDECK-AK</pre>
		<ul class="simple-list">
			<li>Higher-resolution terrain</li>
			<li>Improved road and feature detail</li>
			<li>Better field navigation</li>
		</ul>
	</div>
</section>

<section class="card section">
	<div class="kicker">Combined build script</div>
	<h2 class="section-title">Run the helper script</h2>
<pre>./build-alaska.sh</pre>
	<p class="mini">
		This script builds all Alaska layers in sequence using the same SD target.
	</p>
</section>

<section class="card section">
	<div class="kicker">Example script</div>
	<h2 class="section-title">build-alaska.sh</h2>
<pre>#!/usr/bin/env bash
set -euo pipefail

if [ -d ".venv" ]; then
	source .venv/bin/activate
fi

CARD_TARGET="${1:-TDECK-AK}"
BASE_SOURCE="${2:-terrain}"

run_build() {
	local location="$1"
	local min_zoom="$2"
	local max_zoom="$3"

	./build-core.sh "${location}" "${min_zoom}" "${max_zoom}" "${BASE_SOURCE}" "${CARD_TARGET}"
}

run_build "Alaska" 4 7
run_build "Fairbanks, Alaska" 6 12
run_build "Delta Junction, Alaska" 7 11
run_build "Tok, Alaska" 8 13</pre>
</section>

<section class="grid grid-2 section">
	<div class="card">
		<div class="kicker">Why this works</div>
		<h2 class="section-title">Balanced detail</h2>
		<ul class="simple-list">
			<li>Low zoom -> context</li>
			<li>Mid zoom -> primary operations</li>
			<li>High zoom -> field precision</li>
		</ul>
		<p class="mini">
			This keeps build times reasonable, storage efficient, and map performance smooth on the T-Deck.
		</p>
	</div>

	<div class="card">
		<div class="kicker">What not to do</div>
		<h2 class="section-title">Avoid full Alaska at high zoom</h2>
<pre>./build-core.sh "Alaska" 4 10 terrain TDECK-AK</pre>
		<ul class="simple-list">
			<li>Long build times</li>
			<li>Large storage usage</li>
			<li>Limited practical benefit</li>
		</ul>
	</div>
</section>

<section class="card section">
	<div class="kicker">Summary</div>
	<h2 class="section-title">Recommended Alaska stack</h2>
	<ul class="simple-list">
		<li>Alaska -> context</li>
		<li>Fairbanks -> core detail</li>
		<li>Delta Junction -> corridor</li>
		<li>Tok -> high detail</li>
	</ul>
	<p>
		This creates a balanced, field-ready map setup for Alaska.
	</p>
</section>
