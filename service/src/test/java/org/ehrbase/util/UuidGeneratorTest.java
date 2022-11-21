/*
 * Copyright (c) 2022 vitasystems GmbH and Hannover Medical School.
 *
 * This file is part of project EHRbase
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.ehrbase.util;

import java.util.UUID;
import java.util.stream.IntStream;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

class UuidGeneratorTest {

    @Test
    void randomUuid() {
        Assertions.assertNotNull(UuidGenerator.randomUUID());
        Assertions.assertNotEquals(UuidGenerator.randomUUID(), UuidGenerator.randomUUID());
        // no duplicates are produced in parallel scenario
        Assertions.assertEquals(
                1_000,
                IntStream.range(0, 1_000)
                        .parallel()
                        .mapToObj(i -> UuidGenerator.randomUUID())
                        .distinct()
                        .count());
    }

    @Test
    void testUuidVersionAndVariant() {
        IntStream.range(0, 1_000).forEach(i -> {
            UUID uuid = UuidGenerator.randomUUID();
            Assertions.assertEquals(4, uuid.version());
            Assertions.assertEquals(2, uuid.variant());
        });
    }
}
