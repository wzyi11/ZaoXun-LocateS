import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { SPACE_CREATE_SQL } from '../main/ets/model/SpaceModel';
import { centerImageOffset, clampImageOffset, normalizeImagePoint } from '../main/ets/model/ImageDragModel';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });
    it('assertContain', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'abc';
      let b = 'b';
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    });

    it('spaceSchemaContainsMarkerFields', 0, () => {
      expect(SPACE_CREATE_SQL).assertContain('image TEXT');
      expect(SPACE_CREATE_SQL).assertContain('markerX REAL');
      expect(SPACE_CREATE_SQL).assertContain('markerY REAL');
      expect(SPACE_CREATE_SQL).assertContain('markerColor TEXT');
    });

    it('imageDragMathCentersClampsAndNormalizes', 0, () => {
      const centered: number = centerImageOffset(360, 720);
      expect(centered).assertEqual(-180);

      expect(clampImageOffset(80, 360, 720)).assertEqual(0);
      expect(clampImageOffset(-420, 360, 720)).assertEqual(-360);

      const markerX: number = normalizeImagePoint(180, -180, 720, 0.06, 0.94);
      expect(markerX).assertEqual(0.5);
    });
  });
}
