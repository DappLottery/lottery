<script>
  import { useNavigate } from "svelte-navigator";

  export let defaultPath;

  const navigate = useNavigate();
</script>

{navigate(defaultPath)}