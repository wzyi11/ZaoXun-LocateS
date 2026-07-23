import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { SPACE_CREATE_SQL } from '../main/ets/model/SpaceModel';
import {
  buildEventImportKey,
  formatEventDate,
  formatEventDateTime,
  isCalendarEventAllDay,
  isEventDateWithinNextDays,
  isSystemCalendarEventSkippable,
  parseEventDateStartTime,
} from '../main/ets/model/EventModel';
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

    it('eventDateHelpersUseStableDateOnlyFormat', 0, () => {
      const date: Date = new Date(2026, 6, 5);
      expect(formatEventDate(date)).assertEqual('2026-07-05');
      expect(formatEventDateTime(new Date(2026, 6, 5, 9, 8))).assertEqual('2026-07-05 09:08');

      const startTime: number = parseEventDateStartTime('2026-07-05');
      const parsed: Date = new Date(startTime);
      expect(parsed.getFullYear()).assertEqual(2026);
      expect(parsed.getMonth()).assertEqual(6);
      expect(parsed.getDate()).assertEqual(5);
      expect(parsed.getHours()).assertEqual(0);

      const timedStartTime: number = parseEventDateStartTime('2026-07-05 09:08');
      const timedParsed: Date = new Date(timedStartTime);
      expect(timedParsed.getHours()).assertEqual(9);
      expect(timedParsed.getMinutes()).assertEqual(8);
    });

    it('eventDateHelpersLimitSystemImportToNextThirtyDays', 0, () => {
      const base: Date = new Date(2026, 6, 1);
      expect(isEventDateWithinNextDays(new Date(2026, 6, 1).getTime(), base, 30)).assertTrue();
      expect(isEventDateWithinNextDays(new Date(2026, 6, 31).getTime(), base, 30)).assertTrue();
      expect(isEventDateWithinNextDays(new Date(2026, 7, 1).getTime(), base, 30)).assertFalse();
      expect(isEventDateWithinNextDays(new Date(2026, 5, 30).getTime(), base, 30)).assertFalse();
    });

    it('eventImportHelpersSkipAllDayAndCalendarFestivalEntries', 0, () => {
      const start: number = new Date(2026, 6, 24, 0, 0).getTime();
      const end: number = new Date(2026, 6, 25, 0, 0).getTime();
      expect(isCalendarEventAllDay(true, start, end)).assertTrue();
      expect(isCalendarEventAllDay(false, start, end)).assertTrue();
      expect(isCalendarEventAllDay(false, new Date(2026, 6, 24, 9, 0).getTime(), new Date(2026, 6, 24, 10, 0).getTime())).assertFalse();

      expect(isSystemCalendarEventSkippable('大暑', false, start, end)).assertTrue();
      expect(isSystemCalendarEventSkippable('中伏', false, start, end)).assertTrue();
      expect(isSystemCalendarEventSkippable('拿快递', false, new Date(2026, 6, 24, 9, 0).getTime(), new Date(2026, 6, 24, 10, 0).getTime())).assertFalse();
    });

    it('eventImportKeyUsesTitleAndExactTime', 0, () => {
      const start: number = new Date(2026, 6, 24, 9, 8).getTime();
      expect(buildEventImportKey('  拿快递  ', start)).assertEqual('拿快递|2026-07-24 09:08');
    });
  });
}
