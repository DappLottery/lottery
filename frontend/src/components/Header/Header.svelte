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
		max-width: 1000px;
		height: 70px;
	}

	.logo,
	.title,
	nav {
		position: absolute;
	}

	.logo {
		left: 0%;
		/* padding-left: 30px; */
		text-align: left;
	}

	.title {
		left: 50%;
		transform: translate(-50%, 0);
	}

	nav {
		right: 0%;
		transform: translate(-100%, 0);
		/* padding-right: 10px; */
	}
</style>