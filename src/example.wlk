/** 
Calcular sólo el precio bruto de un pedido, es decir, 
sin tener en cuenta el cliente. 
>> unPedido.precioBruto()

Determinar el costo real de envío de un pedido para un cliente.
>> unPedido.costoRealEnvio(unCliente)

Dado un pedido, saber cual es el valor de envío que debe abonar un cliente 
determinado.
>> unPedido.valorEnvio(unCliente)



Dado un pedido, hacer que un cliente realice una compra. 
Una compra está compuesta por un pedido, además el valor del envío que debe 
abonar y la fecha actual. Para que la compra se pueda realizar, debe cumplirse 
que el local tenga todos los productos.
>> unCliente.realizarCompra(unPedido)
*/

class Pedido {
	// en java: var static topeMaxEnvio
	const local
	const items = #{} //new Dictionary()
	
	//Punto 1
	method precioBruto() = items.sum{ item => item.precio() }
	
	//Punto 2.a
	method costoRealEnvio(unCliente) {
		const cantidadCuadras = calculadorDeCuadras.cuadras(local, unCliente)
		return pedido.topeMaxEnvio().
			min(cantidadCuadras * pedido.costoPorCuadra())
	} 
		
	//Punto 2.b
	method valorEnvio(unCliente) = 
		unCliente.valorEnvio(self.costoRealEnvio(unCliente))
	
}

object pedido { // Object Companion
	var property topeMaxEnvio = 300
	var property costoPorCuadra = 15
}

object calculadorDeCuadras {
	method cuadras(local, cliente) = 10
}

class Item {
	
	const producto
	var cantidad
	
	method precio() = producto.precio() * cantidad 
}

class Producto {
	const property precio
	
	
}

class Compra {
	const property pedido
	const property fecha
	const property valorEnvio
}

class Cliente {
	
	var tipoCliente
	const property compras = []
	
	method valorEnvio(costoRealEnvio) = 
		tipoCliente.valorEnvio(costoRealEnvio)
		
	// Punto 3.b
	method realizarCompra(unPedido) {
		//TODO validar pedido!!!!
		const compra = new Compra(pedido = unPedido,
								 fecha = new Date(),
								 valorEnvio = unPedido.valorEnvio(self))
		compras.add(compra)
		tipoCliente.compraRealizada()
	}
	
	method cantidadDeCompras() = compras.size()
}

object clienteComun {
	
	method compraRealizada() {}
	
	method valorEnvio(costoRealEnvio) = costoRealEnvio
}

object clienteSilver {
	
	method compraRealizada() {}

	method valorEnvio(costoRealEnvio) = costoRealEnvio * 0.5
}

class ClienteGold {
	
	var cantidadCompras = 0
	
	method compraRealizada() {
		cantidadCompras += 1
	}

	method valorEnvio(costoRealEnvio) {
		if (cantidadCompras > 0 && 
			cantidadCompras % clienteGold.cantidadDeComprasPorPromo() == 0) return 0
		else return costoRealEnvio * 0.1
	}
	
}

object clienteGold {	
	var property cantidadDeComprasPorPromo = 5
}