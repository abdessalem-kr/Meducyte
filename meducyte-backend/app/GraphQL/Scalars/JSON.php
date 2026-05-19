<?php

namespace App\GraphQL\Scalars;

use GraphQL\Error\Error;
use GraphQL\Language\AST\Node;
use GraphQL\Type\Definition\ScalarType;
use GraphQL\Utils\Utils;

class JSON extends ScalarType
{
    /**
     * Serializes an internal value to include in a response.
     *
     * @param  mixed  $value
     * @return mixed
     */
    public function serialize($value)
    {
        return $value;
    }

    /**
     * Parses an externally provided value (query variable) to use as an input.
     *
     * @param  mixed  $value
     * @return mixed
     */
    public function parseValue($value)
    {
        return $value;
    }

    /**
     * Parses an externally provided literal value (embedded in a GraphQL query) to use as an input.
     *
     * @param  \GraphQL\Language\AST\ValueNode  $valueNode
     * @param  array<string, mixed>|null  $variables
     * @return mixed
     */
    public function parseLiteral(Node $valueNode, ?array $variables = null)
    {
        if (property_exists($valueNode, 'value')) {
            return $valueNode->value;
        }

        if (isset($valueNode->fields)) {
            $value = [];
            foreach ($valueNode->fields as $field) {
                $value[$field->name->value] = $this->parseLiteral($field->value, $variables);
            }
            return $value;
        }

        if (isset($valueNode->values)) {
            $value = [];
            foreach ($valueNode->values as $v) {
                $value[] = $this->parseLiteral($v, $variables);
            }
            return $value;
        }

        return null;
    }
}
