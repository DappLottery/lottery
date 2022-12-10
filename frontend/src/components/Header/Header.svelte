<script>
	import Logo from "./Logo.svelte";
	import Nav from "./Nav.svelte";
</script>

<header>
	<div class="logo">
		<Logo />
	</div>

	<nav>
		<Nav />
	</nav>
</header>

<style>
	header {
		position: relative;
		/* width: 80vw; */
		width: 1000px;
		height: 70px;
	}

	.logo,
	nav {
		position: absolute;
	}

	.logo {
		left: 0%;
		text-align: left;
	}

	nav {
		right: 0%;
	}
</style>