<?php defined('SYSPATH') or die('No direct script access.');

/**
 * Credis-specific errors, wraps native Redis errors
 *
 * @package Redis
 */
class Credis_Exception extends Exception {

    const CODE_TIMED_OUT = 1;
    const CODE_DISCONNECTED = 2;

    public function __construct($message, $code = 0, $exception = NULL)
    {
        if ($exception && get_class($exception) == 'RedisException' && $message == 'read error on connection')
        {
            $code = Credis_Exception::CODE_DISCONNECTED;
        }

        parent::__construct($message, $code, $exception);
    }

}
