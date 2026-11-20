<?php

namespace App\Events;

use App\Models\Mosque;
use Illuminate\Foundation\Events\Dispatchable;

class MosqueRegistered
{
    use Dispatchable;

    public function __construct(public readonly Mosque $mosque) {}
}
