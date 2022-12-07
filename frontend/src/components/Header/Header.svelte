<script>
	import Logo from "./Logo.svelte";
	import Nav from "./Nav.svelte";

	export let selectedAccount;
</script>

<header>
	<div class="logo">
		<Logo {selectedAccount} />
	</div>

	<div class="title">
		<span>Title</span>
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
	.title,
	nav {
		position: absolute;
	}

	.logo {
		left: 0%;
		text-align: left;
	}

	.title {
		left: 50%;
		transform: translate(-50%, 0);
	}

	nav {
		right: 0%;
	}
</style>