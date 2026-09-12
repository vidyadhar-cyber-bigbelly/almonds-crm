@isTest
private class TemperatureConverterTest {
     @isTest static void testWarmTemp(){
        Decimal celsius = TemperatureConverter.FahrenheitToCelsius(100);
        System.assertEquals(37.78,celsius);
    }
}