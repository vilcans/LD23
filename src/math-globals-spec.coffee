describe 'math-globals', ->
  describe 'wrapAngle', ->
    it 'should return the same value if in range', ->
      expect(wrapAngle(1.2)).toEqual(1.2)
    it 'should wrap values above PI', ->
      expect(wrapAngle(Math.PI + .1)).toBeCloseTo(-Math.PI + .1, 5)
    it 'should wrap values below -PI', ->
      expect(wrapAngle(-Math.PI - .1)).toBeCloseTo(Math.PI - .1, 5)
    it 'should wrap values 5 laps above PI', ->
      expect(wrapAngle(Math.PI * 2 * 5 + Math.PI + .1)).toBeCloseTo(-Math.PI + .1, 5)
    it 'should wrap values 5 laps below -PI', ->
      expect(wrapAngle(-Math.PI * 2 * 5 - Math.PI - .1)).toBeCloseTo(Math.PI - .1, 5)
    it 'should wrap values 5 laps below -PI', ->
