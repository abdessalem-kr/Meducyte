<?php

namespace App\GraphQL\Queries\Learn;

use App\Models\Learn\Module;

class ModuleResolver
{
    public function years($root, array $args)
    {
        return Module::distinct()
            ->orderBy('year', 'asc')
            ->pluck('year');
    }

    public function canAccess(Module $module, array $args, $context)
    {
        $user = $context->user();
        if (!$user)
            return false;
        return $user->canAccessModule($module);
    }
}
