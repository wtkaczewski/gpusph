/*  Copyright 2011-2013 Alexis Herault, Giuseppe Bilotta, Robert A. Dalrymple, Eugenio Rustico, Ciro Del Negro

    Istituto Nazionale di Geofisica e Vulcanologia
        Sezione di Catania, Catania, Italy

    Università di Catania, Catania, Italy

    Johns Hopkins University, Baltimore, MD

    This file is part of GPUSPH.

    GPUSPH is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    GPUSPH is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GPUSPH.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _BUILDNEIBS_CUH_
#define _BUILDNEIBS_CUH_

#include "engine_neibs.h"

/* Important notes on block sizes:
	- all kernels accessing the neighbor list MUST HAVE A BLOCK
	MULTIPLE OF NEIBINDEX_INTERLEAVE
	- a parallel reduction for max neibs number is done inside neiblist, block
	size for neiblist MUST BE A POWER OF 2
 */
#if (__COMPUTE__ >= 20)
	#define BLOCK_SIZE_CALCHASH		256
	#define MIN_BLOCKS_CALCHASH		6
	#define BLOCK_SIZE_REORDERDATA	256
	#define MIN_BLOCKS_REORDERDATA	6
	#define BLOCK_SIZE_BUILDNEIBS	256
	#define MIN_BLOCKS_BUILDNEIBS	5
#else
	#define BLOCK_SIZE_CALCHASH		256
	#define MIN_BLOCKS_CALCHASH		1
	#define BLOCK_SIZE_REORDERDATA	256
	#define MIN_BLOCKS_REORDERDATA	1
	#define BLOCK_SIZE_BUILDNEIBS	256
	#define MIN_BLOCKS_BUILDNEIBS	1
#endif

template<BoundaryType boundarytype, Periodicity periodicbound, bool neibcount>
class CUDANeibsEngine : public AbstractNeibsEngine
{
public:
	void
	setconstants(const SimParams *simparams, const PhysParams *physparams,
		float3 const& worldOrigin, uint3 const& gridSize, float3 const& cellSize,
		idx_t const& allocatedParticles);

	void
	getconstants(SimParams *simparams, PhysParams *physparams);

	void
	resetinfo();

	void
	getinfo(TimingInfo &timingInfo);

	void
	calcHash(float4*	pos,
		 hashKey*	particleHash,
		 uint*		particleIndex,
		 const particleinfo* particleInfo,
		 uint*		compactDeviceMap,
		 const uint		numParticles);

	void
	fixHash(hashKey*	particleHash,
			uint*		particleIndex,
			const particleinfo* particleInfo,
			uint*		compactDeviceMap,
			const uint		numParticles);

	void
	reorderDataAndFindCellStart(
		uint*				cellStart,			// output: cell start index
		uint*				cellEnd,			// output: cell end index
		uint*				segmentStart,		// output: segment start

		const hashKey*		particleHash,		// input: sorted grid hashes
		const uint*			particleIndex,		// input: sorted particle indices

		MultiBufferList::iterator sorted_buffers,		// output: sorted buffers
		MultiBufferList::const_iterator unsorted_buffers, // input: buffers to sort

		const uint			numParticles,		// input: number of particles in input buffers
		uint*				newNumParticles);	// output: number of active particles found

	void
	updateVertIDToIndex(const particleinfo*	particleInfo,	// input: particle's information
						uint*			vertIDToIndex,	// output: vertIDToIndex array
						const uint		numParticles);	// input: total number of particles

	void
	buildNeibsList(	neibdata*			neibsList,
					const float4*		pos,
					const particleinfo*	info,
					vertexinfo*			vertices,
					const float4		*boundelem,
					float2*				vertPos[],
					const uint*			vertIDToIndex,
					const hashKey*		particleHash,
					const uint*			cellStart,
					const uint*			cellEnd,
					const uint			numParticles,
					const uint			particleRangeEnd,
					const uint			gridCells,
					const float			sqinfluenceradius,
					const float			boundNlSqInflRad);

	void
	sort(	hashKey	*particleHash,
			uint	*particleIndex,
			uint	numParticles);

};



#endif