<?php

namespace App\Enums;

final class BlockType
{
    public const TEXT = 'TEXT';  
    public const IMAGE = 'IMAGE';  
    public const TABLE = 'TABLE';  
    public const NOTE = 'NOTE';

    public static function values(): array
    {
        return [
            self::TEXT,
            self::IMAGE,
            self::TABLE,
            self::NOTE,
        ];
    }
}