<script>

</script>

<header>
	<div class="account">
		<!-- <Account /> -->
	</div>

	<div class="title">
		<span>Title</span>
	</div>

	<div class="menu">
		<!-- <Menu /> -->
	</div>
</header>

<style>
	header {
		position: relative;
	}

	.account,
	.title,
	.menu {
		position: absolute;
	}

	.account {
		left: 0%;
		padding-left: 30px;
	}

	.title {
		left: 50%;
		transform: translate(-50%, 0);
	}
	
	.menu {
		right: 0%;
		transform: translate(-100%, 0);
		/* padding-right: 10px; */
	}
</style>