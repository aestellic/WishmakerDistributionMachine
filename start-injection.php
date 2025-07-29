<?php
header('Content-Type: text/plain');
header('Cache-Control: no-cache');
header('X-Accel-Buffering: no');
ob_implicit_flush(true);
set_time_limit(0);

// --------------------------------------------------------------------
//    To enable --fill-party, change the next line to the following:
//    $script = __DIR__ . '/injectJirachi.sh --fill-party';
// --------------------------------------------------------------------

$script = __DIR__ . '/injectJirachi.sh';

echo "DEBUG: Starting script: $script\n";
flush();

// set $HOME so flashgbx works
$env = $_ENV;
$env['HOME'] = '/home/wishmaker';


$process = proc_open("bash $script", [
    1 => ['pipe', 'w'], // stdout
    2 => ['pipe', 'w'], // stderr
], $pipes);

if (!is_resource($process)) {
    echo "ERROR: Failed to start script.\n";
    exit(1);
}

stream_set_blocking($pipes[1], false);
stream_set_blocking($pipes[2], false);

while (true) {
    $stdout = fgets($pipes[1]);
    $stderr = fgets($pipes[2]);

    if ($stdout !== false) {
        echo "STDOUT: $stdout";
        flush();
    }

    if ($stderr !== false) {
        echo "STDERR: $stderr";
        flush();
    }

    if ($stdout === false && $stderr === false) {
        // check if process ended
        $status = proc_get_status($process);
        if (!$status['running']) break;
        usleep(100000); // 0.1 sec delay
    }
}

// close pipes
fclose($pipes[1]);
fclose($pipes[2]);

$exitCode = proc_close($process);

echo "DEBUG: Script exited with code $exitCode\n";
flush();

exit($exitCode);
