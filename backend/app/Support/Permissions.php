<?php

namespace App\Support;

use App\Models\Mosque;
use App\Models\MosqueMember;

class Permissions
{
    public static function allows(MosqueMember $member, string $permission, Mosque $mosque): bool
    {
        $granted = config("permissions.{$member->role}", []);
        if (in_array('*', $granted, true) || in_array($permission, $granted, true)) {
            return true;
        }

        return $member->role === 'pengurus'
            && in_array($permission, ['finance.view', 'finance.export'], true)
            && (bool) $mosque->setting('pengurus_can_view_finance');
    }

    /** @return list<string> */
    public static function listFor(MosqueMember $member, Mosque $mosque): array
    {
        $all = collect(config('permissions'))->except('audit_scopes')->flatten()->unique()->reject(fn ($p) => $p === '*');
        $all = $all->merge(['mosque.update', 'members.manage', 'billing.manage'])->unique();

        return $all->filter(fn ($p) => self::allows($member, $p, $mosque))->values()->all();
    }
}
