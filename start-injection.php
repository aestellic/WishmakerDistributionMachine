<?php
// Start output buffering
header('Content-Type: text/plain');
header('Cache-Control: no-cache');
header('X-Accel-Buffering: no'); // For nginx
ob_implicit_flush(true);
set_time_limit(0);

// --------------------------------------------------------------------
//    To enable --fill-party, change the next line to the following:
//    $script = __DIR__ . '/inject_jirachi.sh --fill-party';
// --------------------------------------------------------------------

$script = __DIR__ . '/var/www/html/WishmakerDistributionMachine/injectJirachi.sh';

$process = proc_open("bash $script", [
    1 => ['pipe', 'w'], // stdout
    2 => ['pipe', 'w'], // stderr
], $pipes);

if (!is_resource($process)) {
    echo "ERROR: Failed to start script.\n";
    exit(1);
}

while (!feof($pipes[1])) {
    $line = fgets($pipes[1]);
    if ($line === false) break;

    echo $line;
    flush();
}

$exitCode = proc_close($process);
exit($exitCode);
